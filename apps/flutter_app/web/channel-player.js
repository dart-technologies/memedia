
let queue=[],initialId=null;try{const payload=JSON.parse(decodeURIComponent(location.hash.slice(1)));initialId=payload.startId;queue=(Array.isArray(payload)?payload:payload.items).filter(a=>a&&((a.platform==='YouTube'&&/^yt-[\w-]{11}$/.test(a.id))||(a.platform==='TikTok'&&/^tt-\d+$/.test(a.id))));}catch{}
history.replaceState(null,'',location.pathname);
let index=Math.max(0,queue.findIndex(a=>a.id===initialId)),player=null,frame=null,muted=false,ytReady=false,generation=0,blocked=false;
try{muted=sessionStorage.getItem('memedia-muted')==='true';}catch{}
function soundLabel(){document.getElementById('sound').textContent=blocked?'Play with sound':muted?'Unmute':'Mute';}
function saveSound(){try{sessionStorage.setItem('memedia-muted',String(muted));}catch{}soundLabel();}
const stage=document.getElementById('stage'),status=document.getElementById('status');
function notify(state){if(queue[index])parent.postMessage({type:'memedia-player',id:queue[index].id,state},location.origin);}
function label(s){status.textContent=s||`${index+1}/${queue.length} · ${queue[index]?.title||'No playable media'}`;document.getElementById('previous').disabled=index===0;document.getElementById('next').disabled=index>=queue.length-1;}
function tiktok(type,value){frame?.contentWindow?.postMessage({'x-tiktok-player':true,type,value},'https://www.tiktok.com');}
function show(){generation++;blocked=false;soundLabel();try{player?.destroy();}catch{}player=null;frame=null;stage.replaceChildren();label();const a=queue[index];if(!a)return;notify('loading');
 if(a.platform==='YouTube'){
  if(!ytReady){label('Loading YouTube…');return;}const div=document.createElement('div');stage.append(div);const gen=generation;
  label('Loading YouTube…');player=new YT.Player(div,{host:'https://www.youtube.com',videoId:a.id.slice(3),width:'100%',height:'100%',playerVars:{autoplay:1,playsinline:1,origin:location.origin,rel:0},events:{onReady(e){if(gen!==generation)return;muted?e.target.mute():e.target.unMute();soundLabel();e.target.playVideo();label();},onStateChange(e){if(gen!==generation)return;if(e.data===1){blocked=false;muted=e.target.isMuted();saveSound();notify('playing');}if(e.data===2)notify('paused');if(e.data===0){notify('ended');next();}},onAutoplayBlocked(){if(gen!==generation)return;blocked=true;soundLabel();label('Browser paused autoplay · Play with sound');notify('paused');},onError(){if(gen!==generation)return;label('Embedding unavailable · try Next or source details');notify('unavailable');}}});
 }else{frame=document.createElement('iframe');frame.src=`https://www.tiktok.com/player/v1/${a.id.slice(3)}?autoplay=1&muted=1&controls=1&description=0&music_info=0`;frame.title=a.title;frame.allow='autoplay; fullscreen; encrypted-media';stage.append(frame);muted=true;document.getElementById('sound').textContent='Unmute';}
}
function next(){if(index+1<queue.length){index++;show();}else label('End of channel · choose another media card');}
document.getElementById('next').onclick=next;document.getElementById('previous').onclick=()=>{if(index>0){index--;show();}};
document.getElementById('sound').onclick=()=>{muted=blocked?false:!muted;blocked=false;if(player){muted?player.mute():player.unMute();player.playVideo();}else{if(!muted&&frame?.src.includes('muted=1'))frame.src=frame.src.replace('muted=1','muted=0');else{tiktok(muted?'mute':'unMute');tiktok('play');}}saveSound();};
window.addEventListener('message',e=>{
 if(e.origin===location.origin&&e.source===parent&&e.data?.type==='memedia-queue'){
  try{const updated=JSON.parse(e.data.value).filter(a=>a&&((a.platform==='YouTube'&&/^yt-[\w-]{11}$/.test(a.id))||(a.platform==='TikTok'&&/^tt-\d+$/.test(a.id)))),current=queue[index];if(!updated.length)return;queue=current&&!updated.some(a=>a.id===current.id)?[current,...updated]:updated;index=Math.max(0,queue.findIndex(a=>a.id===current?.id));label();}catch{}return;
 }
if(e.origin!=='https://www.tiktok.com'||e.source!==frame?.contentWindow||!e.data?.['x-tiktok-player'])return;if(e.data.type==='onStateChange'){if(e.data.value===0){notify('ended');next();}else if(e.data.value===1)notify('playing');else if(e.data.value===2)notify('paused');}if(e.data.type==='onPlayerReady')label();if(e.data.type==='onPlayerError'){label('TikTok playback unavailable · try Next or source details');notify('unavailable');}});
window.onYouTubeIframeAPIReady=()=>{ytReady=true;if(queue[index]?.platform==='YouTube')show();};
const script=document.createElement('script');script.src='https://www.youtube.com/iframe_api';document.head.append(script);show();
