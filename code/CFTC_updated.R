#Clear environment
rm(list = ls(all.names = TRUE))

# Import libraries --------------------------------------------------------
library(readxl)
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(stringr)
library(scales)
library(gt)
library(xts)
library(lubridate)
library(ggrepel)
library(RcppRoll)
library(cowplot)

# Custom (RB) palette -------------------------------------------------------------
c1 <- rgb(132/255, 188/255, 156/255,1) 
c2 <- rgb(44/255, 165/255, 141/255,1)
c3 <- rgb(0/255, 92/255, 132/255,1)
c4 <- rgb(0/255, 159/255, 218/255,1)
c5 <- rgb(0/255, 117/255, 176/255,1)
c6 <- rgb(0/255, 15/255, 70/255,1)
c7 <- rgb(88/255, 89/255, 91/255,1)
c8 <- rgb(147/255, 149/255, 152/255,1)
c9 <- rgb(148/255, 124/255, 78/255,1)
c10 <- rgb(0/255, 28/255, 62/255,1)
c11 <- rgb(11/255, 155/255, 215/255,1)
c12 <- rgb(162/255, 197/255, 244/255,1)
c13 <- rgb(80/255, 137/255, 145/255,1)
c14 <- rgb(0/255, 67/255, 70/255,1)

custom_Palette <- c(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14)
# Import CFTC files -------------------------------------------------------
#URLs of CFTC files to download (Disaggregated)
TFF_2022 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2022.zip"
TFF_2021 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2021.zip"
TFF_2020 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2020.zip"
TFF_2019 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2019.zip"
TFF_2018 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2018.zip"
TFF_2017 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2017.zip"
TFF_2016 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2016.zip" #not needed but saved just in case
TFF_2015 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2015.zip" #not needed but saved just in case
TFF_2014 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2014.zip" #not needed but saved just in case
TFF_2013 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2013.zip" #not needed but saved just in case
TFF_2012 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2012.zip" #not needed but saved just in case
TFF_2011 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2011.zip" #not needed but saved just in case
TFF_2010 <- "https://www.cftc.gov/files/dea/history/fut_fin_xls_2010.zip" #not needed but saved just in case
TFF_0616 <- "https://www.cftc.gov/files/dea/history/fin_fut_xls_2006_2016.zip"

# vector of CFTC files to collate
cftc_urls <- c(TFF_2022, TFF_2021, TFF_2020, TFF_2019, TFF_2018, TFF_2017, TFF_0616)

# create empty list and vector output for the for loop 
cftc_list <- vector("list", length = 5)
temp <- vector("integer", length = 5)

#download and unzip directly from FCTC website (this for loop works)
for (i in seq_along(cftc_urls)) {
  temp[[i]] <- tempfile()
  download.file(cftc_urls[[i]], destfile = temp[[i]])
  cftc_list[[i]] <- read_xls(unzip(temp[[i]]))
  unlink(temp)
}

#Un-list and merge data-sets
tff_merged <- do.call(rbind, cftc_list)

# Define functions --------------------------------------------------------
Z_score <- function(x){(x - mean(x, na.rm=TRUE))/sd(x, na.rm=TRUE)}
rollZ_score <- function(x){(x - roll_mean(x, n=156, align="left", fill=NA))/roll_sd(x, n=156, align="left", fill=NA)}
Returns_1m <- function(x) {(log(x) - lag(log(x), 4))*100}
Returns_3m <- function(x) {(log(x) - lag(log(x), 13))*100}
Returns_6m <- function(x) {(log(x) - lag(log(x), 26))*100}
Returns_12m <- function(x) {(log(x) - lag(log(x), 52))*100}

#2022-02-01: The reports this week will have shorter names for some contract markets
# The contract market codes and other data elements are unaffected
# This is a list of the changing names, in alphabetical order of the old name

# Preferred order: CAD, CHF, GBP, JPY, EUR, AUD, NZD 
contract_list <- c("090741", "092741", "096742", "097741", "099741", "232741", "112741")

tff_filter <- tff_merged %>% 
  #Removing variables I do not need
  select(!c(starts_with(c("Traders", "Conc", "Contract", "As_of_Date", "FutOnly")), 
         "CFTC_Market_Code", "CFTC_Region_Code", "CFTC_Commodity_Code", "CFTC_SubGroup_Code")) %>%
  filter(CFTC_Contract_Market_Code %in% contract_list) %>% 
  mutate(AM_Net = Asset_Mgr_Positions_Long_All - Asset_Mgr_Positions_Short_All,
         LM_Net = Lev_Money_Positions_Long_All - Lev_Money_Positions_Short_All,
         DL_Net = Dealer_Positions_Long_All - Dealer_Positions_Short_All,
         Oth_Net = Other_Rept_Positions_Long_All - Other_Rept_Positions_Short_All,
         NRp_Net = NonRept_Positions_Long_All - NonRept_Positions_Short_All,
         TRp_Net = Tot_Rept_Positions_Long_All - Tot_Rept_Positions_Short_All,
         AM_Net_Chg = Change_in_Asset_Mgr_Long_All - Change_in_Asset_Mgr_Short_All,
         LM_Net_Chg = Change_in_Lev_Money_Long_All - Change_in_Lev_Money_Short_All,
         DL_Net_Chg = Change_in_Dealer_Long_All - Change_in_Dealer_Short_All,
         Oth_Net_Chg = Change_in_Other_Rept_Long_All - Change_in_Other_Rept_Short_All,
         NRp_Net_Chg = Change_in_NonRept_Long_All - Change_in_NonRept_Short_All,
         TRp_Net_Chg = Change_in_Tot_Rept_Long_All - Change_in_Tot_Rept_Short_All,
         AM_Net_Pct = Pct_of_OI_Asset_Mgr_Long_All - Pct_of_OI_Asset_Mgr_Short_All,
         LM_Net_Pct = Pct_of_OI_Lev_Money_Long_All - Pct_of_OI_Lev_Money_Short_All,
         DL_Net_Pct = Pct_of_OI_Dealer_Long_All - Pct_of_OI_Dealer_Short_All,
         Oth_Net_Pct = Pct_of_OI_Other_Rept_Long_All - Pct_of_OI_Other_Rept_Short_All,
         NRp_Net_Pct = Pct_of_OI_NonRept_Long_All - Pct_of_OI_NonRept_Short_All,
         TRp_Net_Pct = Pct_of_OI_Tot_Rept_Long_All - Pct_of_OI_Tot_Rept_Short_All) %>% 
  mutate(Market_and_Exchange_Names = ifelse(CFTC_Contract_Market_Code == "090741", "CAD",
                                            ifelse(CFTC_Contract_Market_Code == "092741", "CHF", 
                                                   ifelse(CFTC_Contract_Market_Code == "096742", "GBP",
                                                          ifelse(CFTC_Contract_Market_Code == "097741", "JPY",
                                                                 ifelse(CFTC_Contract_Market_Code == "099741", "EUR",
                                                                        ifelse(CFTC_Contract_Market_Code == "232741", "AUD",
                                                                               ifelse(CFTC_Contract_Market_Code == "112741", "NZD", "error"))))))))

chg_tff_fx <- tff_filter %>% 
  filter(Report_Date_as_MM_DD_YYYY == max(Report_Date_as_MM_DD_YYYY)) %>%
  select(Market_and_Exchange_Names, Report_Date_as_MM_DD_YYYY,
         Change_in_Open_Interest_All,
         Change_in_Asset_Mgr_Long_All, Change_in_Asset_Mgr_Short_All,
         Change_in_Lev_Money_Long_All, Change_in_Lev_Money_Short_All,
         AM_Net_Chg, LM_Net_Chg) %>% 
  rename("Asset" = "Market_and_Exchange_Names",
         "Date" = "Report_Date_as_MM_DD_YYYY",
         "OI Chg" = "Change_in_Open_Interest_All",
         "AM (L) Chg" = "Change_in_Asset_Mgr_Long_All",
         "AM (S) Chg" = "Change_in_Asset_Mgr_Short_All",
         "AM Net Chg" = "AM_Net_Chg",
         "LM (L) Chg" = "Change_in_Lev_Money_Long_All",
         "LM (S) Chg" = "Change_in_Lev_Money_Short_All",
         "LM Net Chg" = "LM_Net_Chg")

#Change in positions w/w
plot_chg_tff_fx <- chg_tff_fx %>% 
  select(Asset, `AM Net Chg`, `LM Net Chg`, `OI Chg`) %>% 
  pivot_longer(cols = 2:4) %>% 
  ggplot(aes(x=name, y=value)) + 
  geom_col(aes(fill=name)) +
  geom_label(aes(x=name, y=1.1*value, label=value, angle=0), 
             fill="white", col="black", size = 2, show.legend = F) +
  facet_grid(.~Asset) +
  theme(legend.title = element_blank(), legend.position = "bottom",
        axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  scale_fill_manual(values = custom_Palette) +
  scale_color_manual(values = custom_Palette) +
  labs(title = "Change in net positioning",
       subtitle = "By investor type; Excluding Other and non-reportables",
       x = NULL, y = "No. of contracts",
       caption = paste("Source: CFTC; As of", max(chg_tff_fx$Date),
                       "\n AM = Asset Managers, LM = Leveraged Money | L = Long, S = Short"))
print(plot_chg_tff_fx)

# Detailed change in positions w/w
## Created dataset to highlight net positions
highlight_AM_week_changes <- chg_tff_fx %>% 
  select(Asset, `AM Net Chg`) %>% 
  pivot_longer(cols = 2)

# AM (detailed)
plot_chg_tff_fx_detailed_AM <- chg_tff_fx %>%
  mutate(`AM (S) Chg` = -1*`AM (S) Chg`) %>% 
  pivot_longer(cols = 3:ncol(chg_tff_fx)) %>% 
  select(-Date) %>% 
  filter(!name %in% c("AM Net Chg", "LM Net Chg", "OI Chg", "LM (L) Chg", "LM (S) Chg")) %>% 
  ggplot(aes(x=Asset, y=value, fill=name)) + 
  geom_col() +
  theme(legend.title = element_blank(), legend.position = "bottom") +
  scale_fill_manual(values = custom_Palette,
                    limits = c("AM (L) Chg", "AM (S) Chg")) +
  geom_hline(yintercept=0, linetype="dashed") +
  labs(title="Change in net positioning (Detailed)",
       subtitle = "Asset Managers",
       x = NULL, y = "No. of contracts",
       caption = paste("Source: CFTC; As of", max(chg_tff_fx$Date),
                       "\n AM = Asset Managers | L = Long, S = Short",
                       "\n AM (Net) = Red",
                       "\n +ve changes in short positions indicate closures")) +
  geom_point(data=highlight_AM_week_changes, aes(x=Asset, y=value, col=name), 
             show.legend = F, size=2) +
  geom_label_repel(data=highlight_AM_week_changes, aes(x=Asset, y=1.1*value, label=value, angle=0), 
                   fill="white", col="black", size = 2.5, show.legend = F, segment.color="white") +
  scale_color_manual(values=c("red")) +
  coord_flip()

# LM (detailed)
highlight_LM_week_changes <- chg_tff_fx %>% 
  select(Asset, `LM Net Chg`) %>% 
  pivot_longer(cols = 2)

plot_chg_tff_fx_detailed_LM <- chg_tff_fx %>%
  mutate(`LM (S) Chg` = -1*`LM (S) Chg`) %>% 
  pivot_longer(cols = 3:ncol(chg_tff_fx)) %>% 
  select(-Date) %>% 
  filter(!name %in% c("AM Net Chg", "LM Net Chg", "OI Chg", "AM (L) Chg", "AM (S) Chg")) %>% 
  ggplot(aes(x=Asset, y=value, fill=name)) + 
  geom_col() +
  theme(legend.title = element_blank(), legend.position = "bottom") +
  scale_fill_manual(values = c(c6, c4),
                    limits = c("LM (L) Chg", "LM (S) Chg")) +
  geom_hline(yintercept=0, linetype="dashed") +
  labs(title="",
       subtitle = "Leveraged Money",
       x = NULL, y = "No. of contracts",
       caption = paste("Source: CFTC; As of", max(chg_tff_fx$Date),
                       "\n LM = Leveraged Money | L = Long, S = Short",
                       "\n LM (Net) = Red",
                       "\n +ve changes in short positions indicate closures")) +
  geom_point(data=highlight_LM_week_changes, aes(x=Asset, y=value, col=name), 
             show.legend = F, size=2) +
  geom_label_repel(data=highlight_LM_week_changes, aes(x=Asset, y=1.1*value, label=value, angle=0), 
                   fill="white", col="black", size = 2.5, show.legend = F, segment.color="white") +
  scale_color_manual(values=c("red")) +
  coord_flip()

plt_chg_tff_fx_detailed_AMLM <- plot_grid(plot_chg_tff_fx_detailed_AM, plot_chg_tff_fx_detailed_LM, ncol = 2, nrow =1)
print(plt_chg_tff_fx_detailed_AMLM)

#Positioning across history (By investor type)
tff_fx_net <- tff_filter %>%
  mutate(Report_Date_as_MM_DD_YYYY = as.Date(Report_Date_as_MM_DD_YYYY)) %>% 
  select(Market_and_Exchange_Names, Report_Date_as_MM_DD_YYYY, 
         Pct_of_OI_Asset_Mgr_Long_All, Pct_of_OI_Asset_Mgr_Short_All, AM_Net_Pct,
         Pct_of_OI_Lev_Money_Long_All, Pct_of_OI_Lev_Money_Short_All, LM_Net_Pct) %>% 
  rename("Asset" = "Market_and_Exchange_Names",
         "Date" = "Report_Date_as_MM_DD_YYYY",
         "AM (L)" = "Pct_of_OI_Asset_Mgr_Long_All",
         "AM (S)" = "Pct_of_OI_Asset_Mgr_Short_All",
         "AM (Net)" = "AM_Net_Pct",
         "LM (L)" = "Pct_of_OI_Lev_Money_Long_All",
         "LM (S)" = "Pct_of_OI_Lev_Money_Short_All",
         "LM (Net)" = "LM_Net_Pct")

# Data wrangling for Leveraged Money positions ----------------------------
tff_fx_net_lm_only <- tff_fx_net %>% 
  select(Asset, Date, `LM (Net)`) %>% 
  spread(key = "Asset", value = "LM (Net)")

tff_net_xts <- as.xts(tff_fx_net_lm_only[,-1], order.by = tff_fx_net_lm_only$Date)
tff_net_standardised_xts <- as.xts(as.data.frame(lapply(tff_net_xts, Z_score)))
tff_net_standardised_df_USDinc <- data.frame(Date = ymd(index(tff_net_standardised_xts)), 
                                             coredata(tff_net_standardised_xts))
tff_net_standardised_df <- tff_net_standardised_df_USDinc[,1:ncol(tff_net_standardised_df_USDinc)-1]

tff_fx_lm_net_spread <- tff_net_standardised_df_USDinc %>% 
  group_by(Date) %>% 
  dplyr::mutate(USD_proxy = -mean(c(AUD, CAD, CHF, EUR, GBP, JPY, NZD), na.rm=T)) %>% 
  gather("Asset", "LM_Z", 2:(ncol(tff_net_standardised_df_USDinc)+1))

# Data wrangling for Asset Manager positions ----------------------------
tff_fx_net_am_only <- tff_fx_net %>% 
  select(Asset, Date, `AM (Net)`) %>% 
  spread(key = "Asset", value = "AM (Net)")

tff_net_xts_AM <- as.xts(tff_fx_net_am_only[,-1], order.by = tff_fx_net_am_only$Date)
tff_net_standardised_xts_AM <- as.xts(as.data.frame(lapply(tff_net_xts_AM, Z_score)))
tff_net_standardised_df_USDinc_AM <- data.frame(Date = ymd(index(tff_net_standardised_xts_AM)), 
                                                coredata(tff_net_standardised_xts_AM))
tff_net_standardised_df_AM <- tff_net_standardised_df_USDinc_AM[,1:ncol(tff_net_standardised_df_USDinc_AM)-1]

tff_fx_am_net_spread <- tff_net_standardised_df_USDinc_AM %>% 
  group_by(Date) %>% 
  dplyr::mutate(USD_proxy = -mean(c(AUD, CAD, CHF, EUR, GBP, JPY, NZD), na.rm=T)) %>% 
  gather("Asset", "AM_Z", 2:(ncol(tff_net_standardised_df_USDinc_AM)+1))

tff_fx_comb_spread <- cbind(tff_fx_am_net_spread, LM_Z=tff_fx_lm_net_spread$LM_Z)

# AM + LM Positioning (Standardized) --------------------------------------
plot_tff_comb_spread <- tff_fx_comb_spread %>% 
  pivot_longer(cols=c("AM_Z", "LM_Z")) %>% 
  ggplot() + 
  geom_line(aes(x=Date, y=value, col = name)) +
  geom_hline(yintercept = 0, linetype = 1, col = "grey") +
  geom_hline(yintercept = 1, linetype = 2, col = "grey") +
  geom_hline(yintercept = -1, linetype = 2, col = "grey") +
  geom_hline(yintercept = 2, linetype = 2, col = "grey") +
  geom_hline(yintercept = -2, linetype = 2, col = "grey") +
  facet_wrap(~Asset, nrow = 2, ncol = 4) +
  scale_color_manual(values = c(c6, c4)) +
  scale_x_date(labels = date_format("%Y")) +
  labs(title = "CFTC Positioning", subtitle = "Standardized, % of Open Interest",
       x = NULL, y = "Z-Score",
       caption = paste("Source: CFTC\n Average USD positioning against G10 FX (EUR, GBP, JPY, CHF, AUD, NZD, CAD) 
                       As of", max(tff_fx_comb_spread$Date))) +
  theme(legend.title=element_blank(),
        legend.position = "bottom",
        axis.line = element_line(color = "grey50"),
        strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        panel.background = element_blank(),
        axis.text.x = element_text(size=7, angle = 0, hjust=0.5))
print(plot_tff_comb_spread)

# Calculating rolling 4-weekly flows
tff_flows <- tff_filter %>% 
  group_by(Market_and_Exchange_Names) %>% 
  
  # Creating 4-weekly flows
  mutate(rollAM_net_chg = roll_sum(AM_Net_Chg, n=4, align='left', fill=NA),
         rollLM_net_chg = roll_sum(LM_Net_Chg, n=4, align='left', fill=NA),
         rollDL_net_chg = roll_sum(DL_Net_Chg, n=4, align='left', fill=NA),
         rollOth_Net_Chg = roll_sum(Oth_Net_Chg, n=4, align="left", fill=NA),
         rollNRp_Net_Chg = roll_sum(NRp_Net_Chg, n=4, align="left", fill=NA),
         rollTRp_Net_Chg = roll_sum(TRp_Net_Chg, n=4, align="left", fill=NA)) %>% 
  select(-CFTC_Contract_Market_Code) %>% 
  mutate(across(.cols = 2:76, .fns = rollZ_score, .names = "{.col}_Zscore")) %>% 
  rename("Asset" = "Market_and_Exchange_Names", "Date" = "Report_Date_as_MM_DD_YYYY") %>% 
  mutate(Date = as.Date(Date))

flow_stock_fx_AM <- tff_flows %>% 
  filter(Date == max(Date)) %>%
  ggplot() +
  geom_point(aes(y=rollAM_net_chg_Zscore, x=AM_Net_Zscore, col=Asset), size = 4, alpha = 0.8) +
  geom_text_repel(aes(y=rollAM_net_chg_Zscore, x=AM_Net_Zscore, label=Asset), size=3) +
  geom_vline(xintercept =0, col="black", linetype=2) +
  geom_hline(yintercept =0, col="black", linetype=2) +
  scale_color_manual(values = custom_Palette) +
  theme(legend.position = "none") +
  labs(title = "FX Flows vs. Stock (Futures)", subtitle = "Asset Manager Positioning", y="4-week rolling flows\n(3-year rolling Z Score)", x="Net Positioning\n(3-year rolling Z Score)",
       caption = "")

flow_stock_fx_LM <- tff_flows %>% 
  filter(Date == max(Date)) %>%
  ggplot() +
  geom_point(aes(y=rollLM_net_chg_Zscore, x=LM_Net_Zscore, col=Asset), size = 4, alpha = 0.8) +
  geom_text_repel(aes(y=rollLM_net_chg_Zscore, x=LM_Net_Zscore, label=Asset), size=3) +
  geom_vline(xintercept =0, col="black", linetype=2) +
  geom_hline(yintercept =0, col="black", linetype=2) +
  scale_color_manual(values = custom_Palette) +
  theme(legend.position = "none") +
  labs(title="", subtitle = "Leveraged Money Positioning", y="4-week rolling flows\n(3-year Z Score)", x="Net Positioning\n(3-year rolling Z Score)",
       caption = paste("Source: CFTC; As of", max(chg_tff_fx$Date)))

flow_stock_comb <- plot_grid(flow_stock_fx_AM, flow_stock_fx_LM, ncol = 2, nrow =1)
print(flow_stock_comb)
  
for (i in unique(tff_flows$Asset)){
  print(
    tff_flows %>% 
      filter(Asset == i) %>% 
      filter(Date >= max(Date) - 1000) %>%
      ggplot() +
      geom_line(aes(x=Date, y=rollAM_net_chg_Zscore, col="Asset Managers"), size=1) +
      geom_line(aes(x=Date, y=rollLM_net_chg_Zscore, col="Leveraged Funds"), size=1) +
      geom_line(aes(x=Date, y=rollOth_Net_Chg_Zscore, col="Others"), size=1) +
      geom_hline(yintercept = 0, col="black", linetype=2) +
      scale_color_manual(name = "Investor Type", 
                         values = c("Asset Managers" = c6, "Leveraged Funds" = c4, 
                                    "Others" = c2)) +
      scale_x_date(labels = date_format("%b-%y"), breaks = "8 months") +
      labs(title = i, subtitle = "4-week rolling flows (Standardised)",
           x = NULL, y = "Z Score",
           caption = paste("Source: CFTC \n As of", max(tff_flows$Date)))
  )
}

#  Loop for asset manager positioning for FX ------------------------------
for (i in unique(tff_fx_net$Asset)){
  out <- tff_fx_net %>%
    filter(Asset == i) %>%
    ggplot() +
    geom_area(aes(x=Date, y=`AM (L)`), fill=c2, alpha=0.7) +
    geom_area(aes(x=Date, y=-`AM (S)`), fill="red", alpha=0.7) +
    geom_line(aes(x=Date, y=`AM (Net)`), col="black", size=1) +
    scale_fill_manual(values = c(c2, "red", "black")) +
    scale_x_date(labels = date_format("%b-%Y"), breaks = "20 months") +
    labs(title = i, subtitle = "Asset Manager Positioning",
         x = NULL, y = "% of Open Interest",
         caption = paste("Source: CFTC \n As of", max(tff_fx_net$Date)))
  print(out)
}

#  Loop for leveraged money positioning for FX ------------------------------
for (i in unique(tff_fx_net$Asset)){
  out <- tff_fx_net %>%
    filter(Asset == i) %>%
    ggplot() +
    geom_area(aes(x=Date, y=`LM (L)`), fill=c5, alpha=0.7) +
    geom_area(aes(x=Date, y=-`LM (S)`), fill="red", alpha=0.7) +
    geom_line(aes(x=Date, y=`LM (Net)`), col="black", size=1) +
    scale_fill_manual(values = c(c5, "red", "black")) +
    scale_x_date(labels = date_format("%b-%Y"), breaks = "20 months") +
    labs(title = i, subtitle = "Leveraged Money Positioning",
         x = NULL, y = "% of Open Interest",
         caption = paste("Source: CFTC \n As of", max(tff_fx_net$Date)))
  print(out)
}
