let routeHandler=null,playerHandler=null;
window.memediaRegisterRoute=fn=>{routeHandler=fn;};
window.memediaWriteRoute=(url,push)=>{if(url!==location.href)history[push?'pushState':'replaceState'](null,'',url);};
window.addEventListener('popstate',()=>routeHandler?.(location.href));
window.memediaRegisterPlayer=fn=>{playerHandler=fn;};
window.memediaUpdatePlayer=value=>{for(const frame of document.querySelectorAll('iframe[data-memedia-player]'))frame.contentWindow?.postMessage({type:'memedia-queue',value},location.origin);};
window.addEventListener('message',e=>{
 if(e.origin!==location.origin||e.data?.type!=='memedia-player')return;
 if(![...document.querySelectorAll('iframe[data-memedia-player]')].some(frame=>frame.contentWindow===e.source))return;
 if(typeof e.data.id==='string'&&['loading','playing','paused','ended','unavailable'].includes(e.data.state))playerHandler?.(e.data.id,e.data.state);
});
