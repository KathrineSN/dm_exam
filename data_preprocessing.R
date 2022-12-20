# function which formats the data into the desired layout
data_preprocessing <- function(choice_no, wi_no, lo_no, exclude_data = FALSE){
  
  # choice_no <- as.data.frame(choice_no)
  # wi_no <- as.data.frame(wi_no)
  # lo_no <- as.data.frame(lo_no)
  # # 
  choice_no <- as_tibble(choice_no)
  wi_no <- as_tibble(wi_no)
  lo_no <- as_tibble(lo_no)

  if (exclude_data) { # only for datasets with 100 trials 
    # selecting relevant studies
    choice_no <- choice_no %>% 
      slice(163:181, 292:504) %>% 
      select(1:95) # keep only the 95 first trials
    
    wi_no <- wi_no %>% 
      slice(163:181, 292:504) %>% 
      select(1:95)
    
    lo_no <- lo_no %>% 
      slice(163:181, 292:504) %>% 
      select(1:95) # keep only the 95 first trials
  }
  
  #df_final <- data.frame()
  df_final <- tibble()
  
  for (i in 1:nrow(choice_no)) {
    # creating trial and deck  columns 
    sub_choice = choice_no %>% slice(i) #take the "i" row
    sub_choice = gather(sub_choice, "trial", "deck")
    
    sub_choice <- sub_choice %>% 
      mutate(
        trial = gsub("Choice_", "", trial)
      )
    
    # adding gain column 
    sub_win <- wi_no %>% slice(i)
    sub_win <- gather(sub_win, "trial", "gain")
    sub_win <- sub_win %>% 
      mutate(
        trial = gsub("Wins_", "", trial)
      )
    
    # adding loss
    sub_loss = lo_no %>% slice(i)
    sub_loss <- gather(sub_loss, "trial", "loss")
    sub_loss <- sub_loss %>% 
      mutate(
        trial = gsub("Losses_", "", trial),
        subjID = i # adding subject ID
      )
    
    # join dataframe
    first_join = full_join(sub_choice, sub_win, by = "trial")
    second_join = left_join(first_join, sub_loss, by = "trial")
    
    df_final <- rbind(df_final, second_join)
  }
  
  return(df_final)
}