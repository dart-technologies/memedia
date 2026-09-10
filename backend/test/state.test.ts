import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp,readFile,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {MissionStore} from '../src/state.ts';
import {fixtureArtifacts} from '../src/model.ts';
import {FixtureEditorialProvider} from '../src/providers/openai.ts';
import {initializeSurface,updateScene} from '../src/a2ui.ts';
test('deduplication, context programming, snapshot restore and incremental surface',async()=>{
  const dir=await mkdtemp(join(tmpdir(),'memedia-test-'));
  try{
    const path=join(dir,'state.json');const store=new MissionStore(path,'fixture');await store.init();
    await store.ingest(fixtureArtifacts());const revision=store.state.revision;const id=store.state.missionId;
    await store.ingest(fixtureArtifacts());assert.equal(store.state.revision,revision);
    const decisions=await new FixtureEditorialProvider().program(store.state.artifacts,'business');
    await store.program(decisions,'business');assert.equal(store.state.missionId,id);
    assert.equal(store.state.passenger,'business');
    const restored=new MissionStore(path,'fixture');await restored.init();assert.deepEqual(restored.state,store.state);
    assert.equal((await readFile(path+'.jsonl','utf8')).trim().split('\n').length,2);
    assert(initializeSurface(store.state).includes('createSurface'));
    assert(!updateScene(store.state).includes('createSurface'));
    assert(updateScene(store.state).includes('"path":"/scene"'));
    const live=new MissionStore(path,'live');await live.init();assert.equal(live.state.artifacts.length,0);
  }finally{await rm(dir,{recursive:true,force:true});}
});
