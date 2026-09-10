// Opt-in, same-origin presenter bridge. Ordinary visitors have no control receiver.
if(new URLSearchParams(location.search).get('demo')==='1'){
 let handler=null;
 const actions=new Set(['discovery','showcase','relationships','channel','freshness','timeline','closing','warm']);
 window.memediaRegisterDemo=fn=>{handler=fn;};
 window.memediaDemoStatus=value=>{if(window.opener)window.opener.postMessage({type:'memedia-demo-status',value},location.origin);};
 window.addEventListener('message',e=>{
  if(e.origin!==location.origin||e.source!==window.opener||!e.data||e.data.type!=='memedia-demo-command')return;
  if(e.data.action==='ping'){e.source.postMessage({type:'memedia-demo-ready',ready:!!handler},e.origin);return;}
  if(!handler||!actions.has(e.data.action))return;
  handler(e.data.action);
  e.source.postMessage({type:'memedia-demo-ack',id:e.data.id},e.origin);
 });
}
