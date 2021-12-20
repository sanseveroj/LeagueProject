import pandas as pd
import pymongo
from pymongo import MongoClient
import time
import logging
from riotwatcher import LolWatcher, ApiError

logging.basicConfig(filename='csv_log.txt', level=logging.DEBUG)

api_key = "RGAPI-449a3974-6758-4b60-9d92-9ade7962d847"

watcher = LolWatcher(api_key)

part_info = ['summonerName', 'puuid', 'summonerLevel', 'win']

f_objectives = ['damageDealtToObjectives', 'baronKills', 'dragonKills','objectivesStolen', 'objectivesStolenAssists',
                'neutralMinionsKilled']

f_towers = ['firstTowerKill', 'firstTowerAssist','inhibitorKills','turretKills']

f_damages = ['damageDealtToTurrets', 'damageSelfMitigated','magicDamageDealt', 'magicDamageDealtToChampions', 'magicDamageTaken',
            'physicalDamageDealt','physicalDamageDealtToChampions', 'physicalDamageTaken','totalDamageDealt', 'totalDamageDealtToChampions',
             'totalDamageShieldedOnTeammates', 'totalDamageTaken','trueDamageDealt', 'trueDamageDealtToChampions', 
             'trueDamageTaken', 'totalHealsOnTeammates','totalHeal',   'totalTimeCCDealt','totalUnitsHealed']

f_sight = ['detectorWardsPlaced', 'visionWardsBoughtInGame', 'wardsKilled', 'wardsPlaced','visionScore']

f_champ = ['championName', 'champLevel', 'champExperience', 'individualPosition','role', 'lane','totalMinionsKilled']

f_kdas = ['kills', 'deaths', 'assists',  'firstBloodKill','firstBloodAssist','doubleKills','tripleKills','quadraKills', 'pentaKills','unrealKills', 'bountyLevel','killingSprees']
f_gold = ['goldEarned', 'goldSpent', 'consumablesPurchased', 'itemsPurchased']

feature_list = []
for li in [part_info, f_kdas, f_objectives, f_towers, f_damages, f_sight, f_champ, f_gold]:
    feature_list.extend(li)

    
batch = 10000
i = 0
x= 0
Dic = []
#N = match_col.count_documents(filter={})
N = 2
matches = pd.read_csv("raw_matchlist.csv")

res = matches['matches'].apply(lambda x: x.strip('[""]').split('","'))
res[x][1]
for i in range(0,163022):
    for x in range(0, len(res[i])):
        match = watcher.match.by_id('Asia',res[i][x])
        if match['info']['gameMode'] == 'CLASSIC':
            df = pd.DataFrame(Dic)
            fname = f'{i}-{batch}.csv'
            df.to_csv('data/'+fname, index=False, encoding='UTF-8')
            Dic = []
            curtime = time.strftime("%Y-%m-%d %H:%M:%S")
            print(curtime+' :: '+fname+' was created')
        for part in match['info']['participants']:
            dic = {}
            dic['gameId'] = match['info']['gameId']
            dic['gameDuration'] = match['info']['gameDuration']
            for f in feature_list:
                dic[f] = part[f]
                Dic.append(dic)
        
    i += 1
    df = pd.DataFrame(Dic)
    fname = f'LAST.csv'
    df.to_csv('data/'+fname, index=False, encoding='UTF-8')
    



