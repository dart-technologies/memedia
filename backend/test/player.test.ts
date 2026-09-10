import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {runInNewContext} from 'node:vm';
const source=readFileSync(new URL('../../apps/flutter_app/web/channel-player.js',import.meta.url),'utf8');
function harness(saved?:string){
 const elements:any=Object.fromEntries(['stage','status','previous','next','sound'].map(id=>[id,{textContent:'',disabled:false,append(){},replaceChildren(){}}]));
 const calls:string[]=[];let options:any;let value=saved;
 const window:any={addEventListener(){}};
 const target={mute(){calls.push('mute');},unMute(){calls.push('unmute');},playVideo(){calls.push('play');},isMuted(){return false;},destroy(){}};
 const context={window,parent:{postMessage(){}},location:{hash:'#'+encodeURIComponent(JSON.stringify([{id:'yt-12345678901',platform:'YouTube',title:'Test'}])),origin:'https://example.org',pathname:'/channel-player.html'},history:{replaceState(){}},sessionStorage:{getItem(){return value;},setItem(_key:string,v:string){value=v;}},document:{getElementById(id:string){return elements[id];},createElement(){return {};},head:{append(){}}},YT:{Player:class{constructor(_el:any,o:any){options=o;return target;}}}};
 runInNewContext(source,context);window.onYouTubeIframeAPIReady();options.events.onReady({target});
 return {calls,elements,options,target,saved:()=>value};
}
test('YouTube requests audible autoplay by default and respects an explicit mute preference',()=>{
 const fresh=harness();assert.deepEqual(fresh.calls,['unmute','play']);assert.equal(fresh.elements.sound.textContent,'Mute');
 const muted=harness('true');assert.deepEqual(muted.calls,['mute','play']);assert.equal(muted.elements.sound.textContent,'Unmute');
});
test('blocked autoplay offers one explicit audible play action',()=>{
 const h=harness();h.options.events.onAutoplayBlocked();assert.equal(h.elements.sound.textContent,'Play with sound');
 h.elements.sound.onclick();assert.deepEqual(h.calls.slice(-2),['unmute','play']);assert.equal(h.saved(),'false');assert.equal(h.elements.sound.textContent,'Mute');
});
