export const beats = [
  {
    "at": 0,
    "action": "discovery",
    "label": "Discover",
    "voice": "Every moment sparks a thousand reactions. MeMedia brings them into focus."
  },
  {
    "at": 10,
    "action": "showcase",
    "label": "Connected channels",
    "voice": "One launch. First looks, competitive responses, and memes. Related perspectives sit together."
  },
  {
    "at": 20,
    "action": "relationships",
    "label": "Why these connect",
    "voice": "Follow the connection from Samsung’s response to brand banter and visual memes. Each channel explains its editorial lens."
  },
  {
    "at": 30,
    "action": "channel",
    "label": "Watch the moment",
    "voice": "Choose a channel. Watch the story unfold."
  },
  {
    "at": 40,
    "action": "freshness",
    "label": "Astra behind the scenes",
    "voice": "Behind the scenes, Astra screens new metadata for relevance. Here is an actual decision, with its reason."
  },
  {
    "at": 50,
    "action": "timeline",
    "label": "GenUI stays connected",
    "voice": "Through A2UI, fresh evidence updates the same GenUI surface. Your place stays intact. MeMedia. Unfolding moments."
  }
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
