import {beats,DemoTimeline} from './timeline.js';
const $=id=>document.getElementById(id);
let demo=null,ready=false,commandId=0,awaiting=new Map(),recorder=null,stream=null,chunks=[],downloadUrl=null,countdown=null;
const timeline=new DemoTimeline(action=>send(action));
const beatIndex=()=>Math.min(5,Math.floor(timeline.position()/10));
function send(action){if(!ready||!demo||demo.closed)return;const id=++commandId;awaiting.set(id,performance.now());demo.postMessage({type:'memedia-demo-command',action,id},location.origin);}
function setReady(value){ready=value;for(const id of ['warm','capture','start','previous','next','reset'])$(id).disabled=!value;document.querySelectorAll('#beats button').forEach(b=>b.disabled=!value);$('capture').disabled=!value||!!countdown||!!(recorder&&recorder.state!=='inactive');$('pause').disabled=!value||!timeline.running;$('connection').textContent=value?'Demo connected · clean window ready.':'Demo window not connected. Open it to continue.';}
function render(){const t=timeline.position(),i=beatIndex();$('clock').textContent=`00:${Math.floor(t).toString().padStart(2,'0')}`;if(t>=60)$('clock').textContent='01:00';$('progress').value=t;$('label').textContent=beats[i].label;$('voice').textContent=beats[i].voice;$('phase').textContent=t>=60?'Complete':`${timeline.running?'Running':t>0?'Paused':'Ready'} · beat ${i+1} of 6`;$('nextCue').textContent=i<5?`Next at ${beats[i+1].at}s · ${beats[i+1].label}`:t<56?'At 56s · return to the showcase':'Finish on the showcase';document.querySelectorAll('#beats li').forEach((li,n)=>li.classList.toggle('active',n===i));$('pause').disabled=!timeline.running;$('start').textContent=t>=60?'Run again':t>0?'Resume':'Start rehearsal';}
function pause(){timeline.pause();if(recorder?.state==='recording')recorder.pause();render();}
function start(){if(!ready)return;$('issue').textContent='';timeline.start();if(recorder?.state==='paused')recorder.resume();render();}
function cancelCountdown(){if(countdown){clearInterval(countdown);countdown=null;}}
function stopCapture(){cancelCountdown();if(recorder&&recorder.state!=='inactive')recorder.stop();stream?.getTracks().forEach(t=>t.stop());stream=null;$('stop').hidden=true;}
function reset(){cancelCountdown();pause();stopCapture();timeline.reset();render();}
function jump(index){if(!ready)return;timeline.seek(Math.max(0,Math.min(5,index))*10);render();}
window.addEventListener('message',e=>{
 if(e.origin!==location.origin||e.source!==demo)return;
 if(e.data?.type==='memedia-demo-ready'){if(!e.data.ready&&timeline.running)pause();setReady(e.data.ready===true);}
 if(e.data?.type==='memedia-demo-ack')awaiting.delete(e.data.id);
 if(e.data?.type==='memedia-demo-status')$('scan').textContent=String(e.data.value);
});
$('open').onclick=()=>{pause();awaiting.clear();setReady(false);demo=window.open('/?demo=1','memedia-recording-stage');if(!demo)$('issue').textContent='Allow the demo popup, then try again.';};
$('warm').onclick=()=>send('warm');$('start').onclick=start;$('pause').onclick=pause;$('previous').onclick=()=>jump(beatIndex()-1);$('next').onclick=()=>jump(beatIndex()+1);$('reset').onclick=reset;$('stop').onclick=()=>{pause();stopCapture();};
for(const [i,b] of beats.entries()){const li=document.createElement('li'),button=document.createElement('button'),time=document.createElement('span');time.textContent=`${b.at}–${b.at+10}s`;button.append(time,document.createTextNode(b.label));button.disabled=true;button.onclick=()=>jump(i);li.append(button);$('beats').append(li);}
$('capture').onclick=async()=>{
 if(!navigator.mediaDevices?.getDisplayMedia||!window.MediaRecorder){$('issue').textContent='Tab recording is unavailable here. Use Chrome or your usual screen recorder with Start rehearsal.';return;}
 try{
  reset();$('issue').textContent='';
  stream=await navigator.mediaDevices.getDisplayMedia({video:{frameRate:30},audio:false});
  if(!ready||!demo||demo.closed){stopCapture();throw Error('Demo disconnected');}
  const mime=['video/webm;codecs=vp9','video/webm;codecs=vp8','video/webm'].find(t=>MediaRecorder.isTypeSupported(t));
  recorder=new MediaRecorder(stream,mime?{mimeType:mime}:{});chunks=[];
  const activeRecorder=recorder,activeChunks=chunks;
  recorder.ondataavailable=e=>{if(e.data.size)activeChunks.push(e.data);};
  recorder.onstop=()=>{if(downloadUrl)URL.revokeObjectURL(downloadUrl);downloadUrl=URL.createObjectURL(new Blob(activeChunks,{type:activeRecorder.mimeType}));$('download').href=downloadUrl;$('download').download=`memedia-${new Date().toISOString().replace(/[:.]/g,'-')}.webm`;$('download').hidden=false;};
  stream.getVideoTracks()[0].addEventListener('ended',()=>{pause();stopCapture();});
  let left=3;$('issue').textContent=`Recording starts in ${left}…`;$('stop').hidden=false;
  countdown=setInterval(()=>{left--;if(left>0){$('issue').textContent=`Recording starts in ${left}…`;return;}cancelCountdown();if(!ready){stopCapture();return;}$('issue').textContent='Recording clean demo tab · no microphone audio';recorder.start(1000);timeline.reset();start();},1000);
 }catch{stopCapture();$('issue').textContent='Capture was cancelled or unavailable. Rehearsal controls are still ready.';}
};
document.addEventListener('keydown',e=>{if(e.target instanceof HTMLInputElement||e.target instanceof HTMLTextAreaElement)return;if(!ready)return;if(e.code==='Space'){e.preventDefault();timeline.running?pause():start();}else if(e.code==='ArrowRight'){e.preventDefault();jump(beatIndex()+1);}else if(e.code==='ArrowLeft'){e.preventDefault();jump(beatIndex()-1);}else if(e.code==='KeyR'){e.preventDefault();reset();}});
setInterval(()=>{
 if(demo&&!demo.closed){demo.postMessage({type:'memedia-demo-command',action:'ping'},location.origin);}else if(ready){pause();stopCapture();awaiting.clear();setReady(false);}
 if([...awaiting.values()].some(at=>performance.now()-at>5000)){pause();awaiting.clear();$('issue').textContent='Demo did not acknowledge the cue. Reopen the demo window before resuming.';setReady(false);}
 const wasRunning=timeline.running;timeline.tick();if(wasRunning&&!timeline.running)stopCapture();render();
},250);
window.addEventListener('beforeunload',()=>{stream?.getTracks().forEach(t=>t.stop());});
render();
