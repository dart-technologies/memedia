export const beats = [
 {at:0, action:'discovery', label:'Discover', voice:'This is MeMedia: unfolding moments, connecting reactions. iPhone Duo anchors our showcase, while other global conversations unfold around it.'},
 {at:10, action:'showcase', label:'Open the moment', voice:'Open the moment and one story becomes twelve curated channels: first impressions, competitive responses, buying decisions, and the memes people share.'},
 {at:20, action:'relationships', label:'Explain the connections', voice:'Related perspectives sit together. Thumbnail stacks show actual media, and every Why explains the editorial connection. Source marks tell you where it came from.'},
 {at:30, action:'channel', label:'Watch First looks', voice:'Choose a channel and watch here. Established creators lead; views and likes stay visible as observed counts, separate from freshness.'},
 {at:40, action:'freshness', label:'Curation and freshness', voice:'Opening a channel refreshes discovery. Astra screens new metadata for relevance, while the current selection stays available. Publication age and scan time remain distinct.'},
 {at:50, action:'timeline', label:'Follow the reaction', voice:'A2UI updates the same surface as the story develops. Follow the reaction, explore another perspective, and keep the original source within reach. That’s MeMedia.'},
];
export const cues = [...beats.map(({at,action})=>({at,action})),{at:56,action:'closing'}].sort((a,b)=>a.at-b.at);
// The clock measures elapsed time; slow callbacks never accumulate timer drift.
export class DemoTimeline {
 constructor(onCue,now=()=>performance.now()){this.onCue=onCue;this.now=now;this.elapsed=0;this.running=false;this.lastCue=-1;}
 position(){return Math.min(60,this.elapsed+(this.running?(this.now()-this.anchor)/1000:0));}
 emit(){const t=this.position();let i=cues.findLastIndex(c=>c.at<=t);if(i!==this.lastCue){this.lastCue=i;this.onCue(cues[i].action);}return t;}
 start(){if(this.running)return;if(this.elapsed>=60){this.elapsed=0;this.lastCue=-1;}this.anchor=this.now();this.running=true;this.emit();}
 pause(){if(!this.running)return;this.elapsed=this.position();this.running=false;this.emit();}
 tick(){const t=this.emit();if(t>=60){this.elapsed=60;this.running=false;}return t;}
 seek(seconds){this.elapsed=Math.max(0,Math.min(60,seconds));this.anchor=this.now();this.lastCue=-1;this.emit();}
 reset(){this.running=false;this.seek(0);}
}
