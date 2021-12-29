#source('Final_PreProcess.R') # Run if model_data not in env
model_data <- read.csv('model_data.csv')
library("grf")
model_data <- model_data %>% mutate_if(is.numeric, as.numeric) %>% mutate_if(is.numeric, function(x) if_else(is.na(x),0,x))
# Building model ####
m <- causal_forest(X = model_data %>% select(-blueWins, -blue_drag_ind,-match_id) %>% as.matrix(),
              Y = model_data %>% select(blueWins) %>% as.matrix(),
              W = model_data %>% select(blue_drag_ind) %>% mutate(blue_drag_ind = as.numeric(blue_drag_ind)) %>% 
                as.matrix(),
              seed = 1995,
              tune.parameters = 'all')

test_calibration(m)

m$W.hat %>% summary()
## Checking Predictions ####
  # Estimate treatment effects for the training data using out-of-bag prediction.
  tau.hat.oob <- predict(m)
  hist(tau.hat.oob$predictions)
  summary(tau.hat.oob$predictions)
  
  # Estimate the conditional average treatment effect on the full sample (CATE).
  # for all samples:
  average_treatment_effect(m, target.sample = "all")
  # Note 12/22: first drag increase overall win rate 7.8%
  
  # for all treated:
  average_treatment_effect(m, target.sample = "treated")
  # Note 12/22: first drag increase overall win rate for treated less than predicted
  
## Analyzing results ####
  
  # Variable importance by number of splits
  cbind.data.frame(Variable = names(model_data %>% select(-blueWins, -blue_drag_ind,-match_id)),
                   Importance = variable_importance(m)) %>%
    filter(Importance >0) %>%
    filter(Importance >= quantile(Importance,.75)) %>% 
    arrange(desc(Importance)) %>%
    ggplot(aes(y = reorder(Variable, Importance, sum), x = Importance)) + geom_col()

  # Evaulating Heterogeneity
    het_data  <- model_data %>% mutate(predTreatmentEffect = tau.hat.oob$predictions)
    my_tree <- get_tree(m,1)
    for(i in 1:length(my_tree$nodes)) {
      if(my_tree$nodes[[i]]$is_leaf) {
        print(mean(het_data$predTreatmentEffect[my_tree$nodes[[i]]$samples]))
        my_tree$nodes[[i]]$leaf_stats$CATE = round(mean(het_data$predTreatmentEffect[my_tree$nodes[[i]]$samples]),2)
      }
    }
    plot(my_tree)    
  