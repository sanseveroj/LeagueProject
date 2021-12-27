source('Libraries.R')

# Script purpose: Creating final clean data set, loaded from .csv's out of PreProcess.ipynb

### Initial data/load clean ####
  ## all_champ_kills ####
  all_champ_kills <- read.csv('all_champ_kills.csv')
  
  all_champ_kills <- all_champ_kills %>%
    filter(match_id != "KR_")%>% #removes bad matches
    arrange(match_id,frame,victimId) %>%
    fill(x,y) #fills missing x/y coordinates
  names(all_champ_kills)[which(names(all_champ_kills) %in% c('x','y'))] <- c('x_champkills',"y_champkills")
  
  ## all_elite_monster ####
  all_elite_monster <- read.csv('all_elite_monster.csv')
  
  all_elite_monster <- all_elite_monster %>% 
    mutate(x_emonster = str_sub(position
          ,start = str_locate(position,': ')[1]+2
          ,end = str_locate(position,': ')[2]+5)
          ,y_emonster = str_sub(position
                      ,start = str_locate_all(position,": ")[[1]][[2,1]]+2
                      ,end = str_locate_all(position,": ")[[1]][[2,2]]+4)) %>%
    select(-position)
  
  
  all_elite_monster <- all_elite_monster %>%
    filter(match_id != "KR_",!is.na(timestamp) )%>% #removes bad matches/data
    mutate(monsterSubType = as.character(monsterSubType)) %>% # cleaning up monsterSubType
    mutate(monsterSubType = as.factor(if_else(monsterSubType == "", "None", monsterSubType))) 
  
  ## all_item_destroyed.csv ####
  all_item_destroyed <- read.csv('all_item_detroyed.csv')
  # came clean :)
  
  ## all_item_purchased.csv ####
  all_item_purchased <- read.csv('all_item_purchased.csv')
  
  #adds itemid for item_undos
  all_item_purchased <- all_item_purchased %>% 
    mutate(itemId = if_else(is.na(itemId),
                            if_else(afterId == 0, beforeId, afterId),itemId)) 
  # for purchased items convert after/before/goldgain to 0
  all_item_purchased <- all_item_purchased %>% 
    mutate_at(vars(afterId,beforeId,goldGain), 
              function(x) as.numeric(x)) %>%
    mutate_at(vars(afterId,beforeId,goldGain), 
              function(x) if_else(is.na(x),0,x)) 
  
  ## all_level_ups.csv ####
  all_level_ups <- read.csv('all_level_ups.csv')
  
  # comes clean :)
  
  ## all_skill_level_ups.csv ####
  all_skill_level_ups <- read.csv('all_skill_level_ups.csv')
  
  # comes clean :)
  
  ## all_sum_table.csv ####
  all_sum_table <- read.csv('all_sum_table.csv')
  
  # comes clean :)
  
  ## all_turret_plates.csv ####
  all_turret_plates <- read.csv('all_turret_plates.csv')
  
  #adding x/y from position
  all_turret_plates <- all_turret_plates %>%
    mutate(x_turretplates = str_sub(position
                      ,start = str_locate(position,': ')[1]+2
                      ,end = str_locate(position,': ')[2]+5)
          ,y_turretplates = str_sub(position
                       ,start = str_locate_all(position,": ")[[1]][[2,1]]+2
                       ,end = str_locate_all(position,": ")[[1]][[2,2]]+4)) %>%
    select(-position) 
  
  ## all_ward_placed.csv ####
  all_ward_placed <- read.csv('all_ward_placed.csv')
  
  #comes clean :)
  
  ## all_building_kills.csv ####
  all_building_kills <- read.csv('all_building_kills.csv')
  
  #comes clean :)
  

### Aggregating ####
  ## all_champ_kills ####
  champ_participants <- all_champ_kills %>%
    mutate(participantId = as.factor(participantId)) %>%
    group_by(match_id,frame,victimId) %>%
    summarise(ParticipantCount = n_distinct(participantId)) %>%
    spread(victimId,ParticipantCount,fill = 0, sep = "part_") %>% 
    mutate(TotalParticipants = sum(c_across(victimIdpart_1:victimIdpart_10)),
           TotalKills = n_distinct(c_across(victimIdpart_1:victimIdpart_10))-1)
  
  champ_victims <- all_champ_kills %>%
    mutate(participantId = as.factor(participantId),
           i = 1) %>%
    spread(victimId,i, sep = "_", fill = 0) %>% 
    group_by(match_id,frame) %>%
    summarise_at(vars(contains('victimId')),function(x) n_distinct(x)-1)
  
  champ_kills_participants <- champ_participants %>%
    left_join(champ_victims,by = c('match_id', 'frame'))
  
  ## all_elite_monster ####
  all_elite_monster <- all_elite_monster %>% 
    mutate(monsterType = paste(monsterType,monsterSubType,sep = "_"),
           i = 1) %>%
    select(match_id,killerId,monsterType,frame,i) %>% unique() %>%
    spread(monsterType,i,fill = 0) %>% 
    group_by(match_id, killerId, frame) %>%
    mutate(total_kills = sum(c_across(BARON_NASHOR_None:RIFTHERALD_None))) %>%
    filter(total_kills >0) %>% ungroup() %>% 
    select(-total_kills) %>% 
    gather('Type','Value',-1:-3) %>% 
    mutate(Type = paste(Type,killerId, sep = "_")) %>%
    select(-killerId) %>%
    spread(Type,Value,fill = 0) 
    
  ## all_item_destroyed.csv ####
  all_item_destroyed <- all_item_destroyed %>% select(-timestamp,-X,-type) %>%
    mutate(i = 1) %>% unique() %>%
    spread(participantId, i ,0,sep = "item_destroy_p") %>%
    arrange(match_id,frame) %>% 
    group_by(match_id,frame) %>% 
    summarise_at(vars(contains('item')),sum)
  
  names(all_item_destroyed) <- str_replace(names(all_item_destroyed),"participantId","")
  
  ## all_item_purchased.csv ####
  #Gathering total number of items purchased per frame
  all_item_purchased <- all_item_purchased %>% 
    filter(type == "ITEM_PURCHASED") %>%
    group_by(match_id,frame,participantId) %>%
    summarise(i = n_distinct(itemId)) %>%
    spread(participantId,i,0)
  
  #Renaming for easier to understand labels
  names(all_item_purchased)[3:12] <- paste("item_purchased_p",names(all_item_purchased)[3:12],sep = '')
  
  ## all_level_ups.csv ####
  all_level_ups <- all_level_ups %>% 
    select(-X,-type) %>% arrange(match_id,frame,participantId) %>%
    group_by(match_id,frame,participantId) %>%
    summarise(level = n_distinct(level))
  all_level_ups <- all_level_ups %>% 
    spread(participantId,level, sep ="_") %>%
    arrange(match_id,frame) 
  
  ## all_sum_table.csv ####
  all_sum_table <- all_sum_table %>% select(-X) %>%
    gather("Stat","Value", c(-1,-27,-28)) %>%
    mutate(Stat = paste(Stat,index,sep="_")) %>%
    spread(Stat,Value,0)
  
  ## all_turret_plates.csv ####
  all_turret_plates <- all_turret_plates %>% select(match_id,frame,teamId,laneType) %>%
    mutate(i = 1,
           turret_plate = paste(laneType,teamId,sep="_")) %>%
    select(-teamId,-laneType) %>% unique() %>%
    spread(turret_plate,i,0)
  
  ## all_ward_placed.csv ####
  all_ward_placed <- all_ward_placed %>% 
    mutate(ward = paste(wardType,creatorId,sep = "_"),i = 1) %>%
    group_by(match_id,frame,ward) %>%
    summarise(i = sum(i)) %>%
    spread(ward,i,0)
  
  ## all_building_kills.csv ####
  all_building_kills <- all_building_kills %>% 
    mutate(towerkill = paste(buildingType,laneType,towerType,killerId, sep = "_"),
           i = 1) %>%
    group_by(match_id,frame,towerkill) %>%
    summarise(i = sum(i))
  
  all_building_kills <- all_building_kills %>% spread(towerkill,i,0)
    
  ## Merging ####
  rm(all_champ_kills) # removing for memory space
  full_merge <- all_building_kills %>% 
    full_join(champ_kills_participants, by = c('match_id','frame')) %>%
    full_join(all_elite_monster, by = c('match_id','frame')) %>%
    full_join(all_item_destroyed, by = c('match_id','frame')) %>%
    full_join(all_item_purchased, by = c('match_id','frame')) %>%
    full_join(all_level_ups, by = c('match_id','frame')) %>%
    full_join(all_turret_plates, by = c('match_id','frame')) %>%
    full_join(all_ward_placed, by = c('match_id','frame'))
  
  full_merge <- full_merge %>% 
    group_by(match_id, frame) %>%
    slice(1) %>%
    full_join(all_sum_table, by = c('match_id','frame')) 
  
  full_merge <- full_merge %>% ungroup() %>%
    mutate(frame = as.character(frame)) %>% # is this a bug? -- 12/23 
    select(-itemId) %>%
    mutate_if(is.numeric,as.numeric) %>%
    arrange(match_id,frame) %>%
    mutate_if(is.numeric,function(x) if_else(is.na(x),0,x))
  ## Dragon Indicators #### 
    drag_inds <- full_merge %>% 
      group_by(match_id,frame) %>%
      mutate(drag_ind = if_else(sum(c_across(179:233))>0,1,0)) %>%
      select(match_id,frame,drag_ind) %>%
      group_by(match_id) %>%
      filter(drag_ind == 1)
    drag_inds <- drag_inds %>% unique()
    # Attaching dragon names + drag frames
    full_merge <- full_merge %>%
      group_by(match_id, frame) %>%
      slice(1) %>%
      left_join(drag_inds %>% mutate(frame = as.character(frame))
                , by = c('match_id'))
    
    names(full_merge)[names(full_merge) %>% str_detect('frame')] <- c('frame','drag_frame')
    
    full_merge <- full_merge %>%
      mutate(drag_ind = if_else(is.na(drag_ind),0,drag_ind)) %>%
      group_by(match_id) %>%
      fill(drag_frame)

  ## Gathering wins ####
  # -- original code for gathering wins: 
    # raw_win_data <- read.csv("C:/Users/joesa/Downloads/raw_match.csv/raw_match.csv")
    # options(useFancyQuotes = F)
    # raw_wins <- raw_win_data %>%
    #   select(X_id,info.teams) %>%
    #   unique() %>%
    #   mutate(blueWins = as.numeric(str_detect(info.teams,'"teamId":100,"win":true'))) %>%
    #   select(X_id,blueWins)
    # raw_wins %>% write.csv("raw_wins.csv",row.names = F)
  
  #Loading in wins data
  raw_wins <- read.csv('raw_wins.csv')
  names(raw_wins)[1] <- 'match_id'
  full_merge <- full_merge %>%
    left_join(raw_wins, by = "match_id")
  
  ## Data checking ####
  # NA Check
  full_merge %>%
    select_if(is.numeric) %>%
    mutate_all(is.na) %>%
    summarise_all(sum) %>% 
    gather() %>%
    filter(value == 1)
  
  # Mean Check
  full_merge %>%
    select_if(is.numeric) %>%
    summarise_all(mean,na.rm = T) %>% 
    gather() %>%
    filter(value > 0)
  
  # Names Check
  names(full_merge)
    
  

### Setting up game level data set ####
  model_data <- full_merge %>% ungroup() %>%
    mutate(frame = as.numeric(frame),
           drag_frame = as.numeric(drag_frame)) %>%
    group_by(match_id) %>%  
    filter(frame < drag_frame) %>%
    select(-frame) %>%
    group_by(match_id,drag_frame) %>%
    summarise_if(is.numeric, sum) %>% ungroup() %>%
    select(-contains("DRAGON"),-drag_ind) %>%
    mutate(blueWins = if_else(blueWins>0,1,0))
  # one-hot encoded indicating blue side got dragon
  W <- full_merge %>% ungroup() %>%
    mutate(blue_drag_ind = if_else(rowSums(.[c('DRAGON_AIR_DRAGON_1','DRAGON_AIR_DRAGON_2', 'DRAGON_AIR_DRAGON_3',
                                     'DRAGON_AIR_DRAGON_4', 'DRAGON_AIR_DRAGON_5', 'DRAGON_EARTH_DRAGON_1',
                                     'DRAGON_EARTH_DRAGON_2','DRAGON_EARTH_DRAGON_3','DRAGON_EARTH_DRAGON_4',
                                     'DRAGON_EARTH_DRAGON_5','DRAGON_FIRE_DRAGON_1','DRAGON_FIRE_DRAGON_2', 
                                     'DRAGON_FIRE_DRAGON_3','DRAGON_FIRE_DRAGON_4','DRAGON_FIRE_DRAGON_5',
                                     'DRAGON_WATER_DRAGON_1', 'DRAGON_WATER_DRAGON_2', 'DRAGON_WATER_DRAGON_3',
                                     'DRAGON_WATER_DRAGON_4','DRAGON_WATER_DRAGON_5')])>0,1,0)) %>%
    select(match_id, blue_drag_ind) %>% unique()
  
  # attaching outcomes 
  model_data <- model_data %>% left_join(W, by = 'match_id')
  
  
  
  ## Data leakage check (incomplete 12/22/21) ####
  # model_cor <- model_data %>% select_if(is.numeric) %>% as.matrix() %>%
  #   cor() 
  # model_cor[rownames(model_cor) == "blue_drag_ind"]
  # 