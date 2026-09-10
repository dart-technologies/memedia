"""Assemble a local review capture with six ElevenLabs narration beats.
Usage: python3 scripts/render-review.py /absolute/path/to/recording-directory
Requires ffmpeg/ffprobe. Never reads credentials or uploads media.
"""
import json, pathlib, shutil, subprocess, sys, textwrap
root = pathlib.Path(sys.argv[1]).resolve()
ffmpeg, ffprobe = shutil.which('ffmpeg'), shutil.which('ffprobe')
if not ffmpeg or not ffprobe:
    raise SystemExit('ffmpeg and ffprobe are required')
manifest = json.loads((root / 'elevenlabs-manifest.json').read_text())
args = [ffmpeg, '-y', '-hide_banner', '-loglevel', 'warning', '-i', str(root / 'capture.webm')]
for beat in manifest['beats']:
    args += ['-i', str(root / beat['file'])]
filters = []
voice_inputs = []
for i, beat in enumerate(manifest['beats']):
    data = json.loads(subprocess.check_output([ffprobe, '-v', 'quiet', '-show_entries', 'format=duration', '-of', 'json', str(root / beat['file'])]))
    duration = float(data['format']['duration'])
    pace = max(1.0, duration / 9.4)
    delay = int(beat['at'] * 1000 + 250)
    filters.append(f'[{i+1}:a]atempo={pace:.6f},loudnorm=I=-16:TP=-1.5:LRA=7,aresample=48000,adelay={delay}:all=1[a{i}]')
    voice_inputs.append(f'[a{i}]')
filters.append(''.join(voice_inputs) + 'amix=inputs=6:normalize=0,apad,atrim=0:60,asplit=2[voice][voicefile]')
filters.append("[0:a]volume='if(between(t,33.5,39.5),0.7,0.045)':eval=frame[clip]")
filters.append('[clip][voice]amix=inputs=2:normalize=0,alimiter=limit=0.95,apad,atrim=0:60[mix]')
ass = '''[Script Info]
ScriptType: v4.00+
PlayResX: 1920
PlayResY: 1080
WrapStyle: 0
[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Caption,Arial,32,&H00F4F5EF,&H00FFFFFF,&H000A0908,&H000A0908,0,0,0,0,100,100,0,0,1,0,0,2,80,80,46,1
Style: Label,Arial,16,&H00DFF4B8,&H00FFFFFF,&H000A0908,&H000A0908,0,0,0,0,100,100,2,0,1,0,0,8,60,60,45,1
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:00.00,0:01:00.00,Label,,0,0,0,,REVIEW CANDIDATE 01 · ELEVENLABS SYNTHETIC NARRATION
'''
def timestamp(value):
    return f'0:{int(value)//60:02d}:{int(value)%60:02d}.00'
for beat in manifest['beats']:
    text = r'\N'.join(textwrap.wrap(beat['text'], 84))
    ass += f"Dialogue: 0,{timestamp(beat['at'])},{timestamp(beat['at']+10)},Caption,,0,0,0,,{text}\n"
(root / 'captions.ass').write_text(ass)
filters.append("[0:v]setpts=PTS-STARTPTS,scale=1920:-2,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:color=0x080911,setsar=1,fps=30,tpad=stop_mode=clone:stop_duration=1,subtitles=captions.ass[v]")
(root / 'mix-filter.txt').write_text(';\n'.join(filters))
args += ['-filter_complex_script', str(root / 'mix-filter.txt'), '-map', '[v]', '-map', '[mix]', '-t', '60', '-c:v', 'libx264', '-preset', 'fast', '-crf', '19', '-pix_fmt', 'yuv420p', '-c:a', 'aac', '-b:a', '192k', '-movflags', '+faststart', str(root / 'MeMedia-review-cut-01.mp4'), '-map', '[voicefile]', '-t', '60', '-c:a', 'pcm_s16le', str(root / 'voiceover-timed.wav')]
subprocess.run(args, cwd=root, check=True)
print(json.dumps({'video': str(root / 'MeMedia-review-cut-01.mp4'), 'narration': 'ElevenLabs stock Jessica; synthetic', 'durationSeconds': 60}))
