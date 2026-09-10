// Local-only recording preparation. Requires an explicit API key in server env.
import {mkdir,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {beats} from '../apps/flutter_app/web/recording/timeline.js';
const key=process.env.ELEVENLABS_API_KEY;
if(!key)throw Error('Set ELEVENLABS_API_KEY in the private environment file.');
const output=resolve(process.argv[2]??'/tmp/memedia-voiceover');
await mkdir(output,{recursive:true});
const voice=process.env.ELEVENLABS_VOICE_ID??'cgSgspJ2msm6clMCkdW9';
const model='eleven_multilingual_v2';
const manifest=[];
for(const [i,beat] of beats.entries()){
 const text=beat.voice.replace('A2UI','A two U I').replace('GenUI','Gen U I');
 const r=await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${encodeURIComponent(voice)}?output_format=mp3_44100_128`,{
  method:'POST',headers:{'xi-api-key':key,'Content-Type':'application/json'},
  body:JSON.stringify({text,model_id:model,voice_settings:{stability:.55,similarity_boost:.75,style:.15,use_speaker_boost:true,speed:1.0}}),signal:AbortSignal.timeout(60000),
 });
 if(!r.ok)throw Error(`ElevenLabs synthesis failed: HTTP ${r.status} on beat ${i+1}.`);
 const audio=Buffer.from(await r.arrayBuffer());
 if(audio.length<1000)throw Error('Empty synthesis output.');
 const file=`elevenlabs-${i}.mp3`;await writeFile(resolve(output,file),audio);
 manifest.push({at:beat.at,text:beat.voice,spokenText:text,file,voice,model,bytes:audio.length,generatedAt:new Date().toISOString()});
 console.log(JSON.stringify({beat:i+1,bytes:audio.length,status:'synthesized'}));
}
await writeFile(resolve(output,'elevenlabs-manifest.json'),JSON.stringify({syntheticVoice:true,voiceName:'Jessica - Playful, Bright, Warm (stock voice; unless overridden)',beats:manifest},null,2));
