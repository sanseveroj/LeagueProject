from riotwatcher import LolWatcher, ApiError
import pandas as pd

# golbal variables
api_key = 'RGAPI-7a8339e8-9a8c-4c3d-a445-678842f707cd'
watcher = LolWatcher(api_key)
#my_region = 'americas'

matches = pd.read_csv('AllGames/raw_match.csv')["_id"]

watcher.match.timeline_by_match()

all_sum_table = pd.DataFrame()
all_champ_kills = pd.DataFrame()
all_level_ups = pd.DataFrame()
all_item_detroyed = pd.DataFrame()
all_item_purchased = pd.DataFrame()
all_skill_level_ups = pd.DataFrame()
all_building_kills = pd.DataFrame()
all_turret_plates = pd.DataFrame()
all_ward_placed = pd.DataFrame()
all_ward_kill = pd.DataFrame()
all_item_undo = pd.DataFrame()
all_elite_monster= pd.DataFrame()

for m in matches:
  print(m)
  match_detail = watcher.match.by_id('asia',m)
  sum_table = pd.DataFrame()
  champ_kills = pd.DataFrame()
  level_ups = pd.DataFrame()
  item_destroyed = pd.DataFrame()
  item_purchased = pd.DataFrame()
  skill_level_ups = pd.DataFrame()
  building_kills = pd.DataFrame()
  turret_plates = pd.DataFrame()
  ward_placed = pd.DataFrame()
  ward_kill = pd.DataFrame()
  item_undo = pd.DataFrame()
  elite_monster = pd.DataFrame()
  try:
    for i in range(0,len(match_detail['info']['frames'])):
      sum1 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['1']['championStats'],orient = 'index',columns =['sum_1']).T.reset_index()
      sum2 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['2']['championStats'],orient = 'index',columns =['sum_2']).T.reset_index()
      sum3 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['3']['championStats'],orient = 'index',columns =['sum_3']).T.reset_index()
      sum4 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['4']['championStats'],orient = 'index',columns =['sum_4']).T.reset_index()
      sum5 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['5']['championStats'],orient = 'index',columns =['sum_5']).T.reset_index()
      sum6 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['6']['championStats'],orient = 'index',columns =['sum_6']).T.reset_index()
      sum7 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['7']['championStats'],orient = 'index',columns =['sum_7']).T.reset_index()
      sum8 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['8']['championStats'],orient = 'index',columns =['sum_8']).T.reset_index()
      sum9 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['9']['championStats'],orient = 'index',columns =['sum_9']).T.reset_index()
      sum10 = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['participantFrames']['10']['championStats'],orient = 'index',columns =['sum_10']).T.reset_index()
      sum1['frame'] = i
      sum2['frame'] = i
      sum3['frame'] = i
      sum4['frame'] = i
      sum5['frame'] = i
      sum6['frame'] = i
      sum7['frame'] = i
      sum8['frame'] = i
      sum9['frame'] = i
      sum10['frame'] = i
      sum_table = pd.concat([sum_table,pd.concat([sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8,sum9,sum10],axis = 0 )],axis = 0)
      for x in range(0, len(match_detail['info']['frames'][i]['events'])):
        if match_detail['info']['frames'][i]['events'][x]['type'] == 'CHAMPION_KILL':
          temp = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x]['victimDamageReceived'])
          temp['victimId'] = [match_detail['info']['frames'][i]['events'][x]['victimId']]*temp.shape[0]
          temp['x'] = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x]['position'], orient = 'index').T['x']
          temp['y'] = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x]['position'], orient = 'index').T['y']
          champ_kills = pd.concat([champ_kills,temp],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'SKILL_LEVEL_UP':
          temp = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T
          skill_level_ups = pd.concat([skill_level_ups,temp],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'ITEM_DESTROYED':
          item_destroyed = pd.concat([item_destroyed,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'ITEM_PURCHASED':
          item_purchased = pd.concat([item_purchased,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'LEVEL_UP':
          level_ups = pd.concat([level_ups,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'TURRET_PLATE_DESTROYED':
          turret_plates = pd.concat([turret_plates,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'ITEM_UNDO':
          item_purchased = pd.concat([item_purchased,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'WARD_PLACED':
          temp = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T
          ward_placed = pd.concat([ward_placed,temp],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'WARD_KILL':
          temp = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T
          ward_kill = pd.concat([ward_kill,temp],axis = 0)
        elif match_detail['info']['frames'][i]['events'][x]['type'] == 'ELITE_MONSTER_KILL':
          temp_dict = match_detail['info']['frames'][i]['events'][x]
          if list(temp_dict.keys())[0] == 'assistingParticipantIds' :
            del temp_dict['assistingParticipantIds']
          temp = pd.DataFrame.from_dict(temp_dict,orient = 'index').T
          elite_monster = pd.concat([elite_monster,temp],axis = 0)
      champ_kills['frame'] = [i]*champ_kills.shape[0]
      skill_level_ups['frame'] = [i]*skill_level_ups.shape[0]
      item_destroyed['frame'] = [i]*item_destroyed.shape[0]
      item_purchased['frame'] = [i]*item_purchased.shape[0]
      level_ups['frame'] = [i]*level_ups.shape[0]
      building_kills['frame'] = [i]*building_kills.shape[0]
      turret_plates['frame'] = [i]*turret_plates.shape[0]
      ward_placed['frame'] = [i]*ward_placed.shape[0]
      ward_kill['frame'] = [i]*ward_kill.shape[0]
      item_undo['frame'] = [i]*item_undo.shape[0]
      elite_monster['frame'] = [i]*elite_monster.shape[0]
    sum_table['match_id'] = m
    champ_kills['match_id'] = m
    level_ups['match_id'] = m
    item_destroyed['match_id'] = m
    item_purchased['match_id'] = m
    skill_level_ups['match_id'] = m
    building_kills['match_id'] = m
    turret_plates['match_id'] = m
    ward_placed['match_id'] = m
    ward_kill['match_id'] = m
    item_undo['match_id'] = m
    elite_monster['match_id'] = m
    all_sum_table = pd.concat([all_sum_table,sum_table],axis = 0)
    all_champ_kills = pd.concat([all_champ_kills,champ_kills],axis = 0)
    all_level_ups = pd.concat([all_level_ups,level_ups],axis = 0)
    all_item_detroyed = pd.concat([all_item_detroyed,item_destroyed],axis = 0)
    all_item_purchased = pd.concat([all_item_purchased,item_purchased],axis = 0)
    all_skill_level_ups = pd.concat([all_skill_level_ups,skill_level_ups],axis = 0)
    all_building_kills = pd.concat([all_building_kills,building_kills],axis = 0)
    all_turret_plates = pd.concat([all_turret_plates,turret_plates],axis = 0)
    all_ward_placed = pd.concat([all_ward_placed,ward_placed],axis = 0)
    all_ward_kill = pd.concat([all_ward_kill,ward_kill],axis = 0)
    all_item_undo = pd.concat([all_item_undo,item_undo],axis = 0)
    all_elite_monster= pd.concat([all_elite_monster,elite_monster],axis = 0)
  except:
    print(m)

# for x in range(0, len(match_detail['info']['frames'][i]['events'])):
#   if match_detail['info']['frames'][i]['events'][x]['type'] == 'CHAMPION_KILL':
#     temp = pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x]['victimDamageDealt'])
#     temp['victimId'] = [match_detail['info']['frames'][i]['events'][x]['victimId']]*temp.shape[0]
#     champ_kills = pd.concat([champ_kills,temp],axis = 0)
#   elif match_detail['info']['frames'][i]['events'][x]['type'] == 'SKILL_LEVEL_UP':
#     skill_level_ups = pd.concat([skill_level_ups,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
#   elif match_detail['info']['frames'][i]['events'][x]['type'] == 'ITEM_DESTROYED':
#     item_destroyed = pd.concat([item_destroyed,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
#   elif match_detail['info']['frames'][i]['events'][x]['type'] == 'ITEM_PURCHASED':
#     item_purchased = pd.concat([item_purchased,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
#   elif match_detail['info']['frames'][i]['events'][x]['type'] == 'LEVEL_UP':
#     level_ups = pd.concat([level_ups,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
#   elif match_detail['info']['frames'][i]['events'][x]['type'] == 'BUILDING_KILL':
#     building_kills = pd.concat([building_kills,pd.DataFrame.from_dict(match_detail['info']['frames'][i]['events'][x],orient = 'index').T],axis = 0)
