import {test} from 'node:test';
import assert from 'node:assert/strict';
import {DemoTimeline} from '../../apps/flutter_app/web/recording/timeline.js';
test('recording follows timed cues, pauses without drift, seeks and restarts',()=>{
 let now=0;const seen:string[]=[];const clock=new DemoTimeline((cue:string)=>seen.push(cue),()=>now);
 clock.start();assert.deepEqual(seen,['discovery']);
 now=10500;clock.tick();assert.equal(seen.at(-1),'showcase');
 clock.pause();now+=100000;assert.equal(clock.position(),10.5);
 clock.start();now+=9500;clock.tick();assert.equal(seen.at(-1),'relationships');
 clock.seek(30);assert.equal(seen.at(-1),'channel');
 now+=10000;clock.tick();assert.equal(seen.at(-1),'freshness');
 now+=10000;clock.tick();assert.equal(seen.at(-1),'timeline');
 now+=6000;clock.tick();assert.equal(seen.at(-1),'closing');
 now+=4000;clock.tick();assert.equal(clock.position(),60);assert.equal(clock.running,false);
 clock.start();assert.equal(seen.at(-1),'discovery');assert.equal(clock.position(),0);
 clock.reset();assert.equal(clock.running,false);assert.equal(clock.position(),0);
});
test('delayed recording callbacks apply the current cue without replaying skipped actions',()=>{
 let now=0;const seen:string[]=[];const clock=new DemoTimeline((cue:string)=>seen.push(cue),()=>now);
 clock.start();now=45000;clock.tick();assert.deepEqual(seen,['discovery','freshness']);clock.tick();assert.equal(seen.length,2);
});
