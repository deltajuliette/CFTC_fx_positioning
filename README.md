# Visualising FX positioning trends
## Description of publication
This codebook attempts to provide an automated and quick snapshot of FX positioning across different investor types.

The Traders in Financial Futures (TFF) report  separates large traders in the financial markets into the following four categories:
* Dealer/Intermediary
* Asset Manager/Institutional
* Leveraged Funds
* Other Reportables. 

For more details, please refer to the appendix.
*Source: CFTC*

## Making sense of the charts
Our focus is on the following currencies: AUD, CAD, CHF, EUR, GBP, JPY and NZD

**#1: Week-on-week changes in positioning**
This illustrates the change in the number of contracts (net) for each currency (relative to the USD) across different investor types. Net positioning is defined as the difference between the amount of long / short future contracts.

![week-on-week changes](https://github.com/deltajuliette/CFTC_fx_positioning/blob/master/images/wow_chg.png "week-on-week changes")

**#2: Detailed week-on-week changes in positioning**

![detailed week-on-week changes](https://github.com/deltajuliette/CFTC_fx_positioning/blob/master/images/wow_chg_detailed.png "detailed week-on-week changes")

**#3: Overall positiioning trends (Standardized)**
This chart illustrates how stretched a particular currency is (relative to its own history). We calculated a proxy for  aggregate USD positioning by using an average of EUR, GBP, JPY, CHF, AUD, NZD and CAD positions.

![zscores](https://github.com/deltajuliette/CFTC_fx_positioning/blob/master/images/zscores.png "zscores")

**#4: Rolling flows relative to aggregate positioning**

![rollingflows_zscores](https://github.com/deltajuliette/CFTC_fx_positioning/blob/master/images/rollingflows_zscores.png "rollingflows_zscores")

**#5: Net positioning trends (% of open interest)**

![am_nc](https://github.com/deltajuliette/CFTC_fx_positioning/blob/master/images/aud_am_nc.png "am_nc")

![lm_nc](https://github.com/deltajuliette/CFTC_fx_positioning/blob/master/images/aud_lm_nc.png "lm_nc")

## Appendix
### Explanatory notes
The TFF Report: The Commission, by regulation, collects confidential daily large-trader data as part of its market surveillance program. That data, which also support the legacy COT report, is separated into the following categories for the TFF report:
* Dealer/Intermediary
* Asset Manager/Institutional
* Leveraged Funds
* Other Reportables

**Trader Classification**
The TFF report divides the financial futures market participants into the “sell side” and “buy side.” This traditional functional division of financial market participants focuses on their respective roles in the broader marketplace, not whether they are buyers or sellers of futures/option contracts. The category called “dealer/intermediary,” for instance, represents sellside participants. Typically, these are dealers and intermediaries that earn commissions on selling financial products, capturing bid/offer spreads and otherwise accommodating clients. The remaining three categories (“asset manager/institutional;” “leveraged funds;” and “other reportables”) represent the buy-side participants. These are essentially clients of the sell-side participants who use the markets to invest, hedge, manage risk, speculate or change the term structure or duration of their assets.

Staff use Form 40 data and, where appropriate, conversations with traders and other data available to the Commission regarding a trader’s market activities to make a judgment on each trader’s appropriate classification. Some multi-service or multi-functional organizations have centralized their futures trading. In such cases, their Form 40 may show occupations and market usages related to more than one of the new categories. CFTC Division of Market Oversight (DMO) staff place each reportable trader in the most appropriate category based on their predominant activity.

Some parent organizations set up separate reportable trading entities to handle their different businesses or locations. In such cases, each of these entities files a separate Form 40 and is analyzed separately for determining that entity’s proper TFF classification. A trader’s classifications may change over a period of time for a number of reasons. A trader may change the way it uses the markets, may trade additional or fewer commodities or may find that its client base evolves, for example. These changes may cause DMO staff to change a trader’s classifications and categories and/or change the commodities to which a trader’s various classifications apply. Moreover, a trader’s classification may change because the Commission has received additional information about the trader

**Content of the Traders in Financial Futures (TFF) Report**
Dealer/Intermediary: These participants are what are typically described as the “sell side” of the market. Though they may not predominately sell futures, they do design and sell various financial assets to clients. They tend to have matched books or offset their risk across markets and clients. Futures contracts are part of the pricing and balancing of risk associated with the products they sell and their activities. These include large banks (U.S. and non-U.S.) and dealers in securities, swaps and other derivatives.

The rest of the market comprises the “buy-side,” which is divided into three separate categories: 

Asset Manager/Institutional: These are institutional investors, including pension funds, endowments, insurance companies, mutual funds and those portfolio/investment managers whose clients are predominantly institutional.

Leveraged Funds: These are typically hedge funds and various types of money managers, including registered commodity trading advisors (CTAs); registered commodity pool operators (CPOs) or unregistered funds identified by CFTC.3 The strategies may involve taking outright positions or arbitrage within and across markets. The traders may be engaged in managing and conducting proprietary futures trading and trading on behalf of speculative clients.

Other Reportables: Reportable traders that are not placed into one of the first three categories are placed into the “other reportables” category. The traders in this category mostly are using markets to hedge business risk, whether that risk is related to foreign exchange, equities or interest rates. This category includes corporate treasuries, central banks, smaller banks, mortgage originators, credit unions and any other reportable traders not assigned to the other three categories.

Spreading: The TFF sets out open interest by long, short, and spreading for all four categories of traders. “Spreading” is a computed amount equal to offsetting long and short positions held by a trader. The computed amount of spreading is calculated as the amount of offsetting futures in different calendar months or offsetting futures and options in the same or different calendar months. Any residual long or short position is reported in the long or short column. Inter-market spreads are not considered.

**Numbers of Traders**
The sum of the numbers of traders in each separate category typically exceeds the total number of reportable traders. This results from the fact that “spreading” can be a partial activity, so the same trader can fall into either the outright “long” or “short” trader count as well as into the “spreading” count. In order to preserve the confidentiality of traders, for any given commodity where a specific category has fewer than four active traders, the size of the relevant positions will be provided but the trader count will not be (specifically, a “·” will appear for trader counts of fewer than four traders).

**Historical Data**
Historical data for the TFF report will soon be available back to June 13, 2006. Note that the CFTC does not maintain a history of large-trader classifications, so, recent classifications had to be used to classify the historical positions of each reportable trader. Due to shifts in trader classifications over time (as discussed above), this “backcasting” approach diminishes the data’s accuracy as it goes further back in time. Nonetheless, the data back as far as 2006 should be reasonably representative of trader classifications over that period. Comparison of the TFF Report to the Legacy COT Report and to the Disaggregated COT Report for Physical Commodities

The legacy COT reports divide reportable traders into the two broad categories of “commercial” and “non-commercial.” The “commercial” trader category has always included traders who report that they manage their business risks by hedging in futures. Everyone else is classified as “non-commercial.” The Disaggregated COT report for physical commodities separates each of the two broad categories (commercial and non-commercial) into two groups. The commercials are separated into the more traditional group of “producer/merchant/processor/user,” who incur risk from dealing in the physical commodity, and “swap dealers,” who incur risk in the over-thecounter (OTC) derivatives market. The Disaggregated COT report for physical commodities breaks the “non-commercial” category of the legacy COT into “managed money” and “other reportables.” [See the Explanatory Notes for the Disaggregated COT for a more complete explanation at http://www.cftc.gov/ucm/groups/public/@newsroom/documents/file/disaggregatedcotexplanator ynot.pdf]

The Disaggregated COT report data for physical commodity markets can be re-aggregated to get back to the two categories of the COT report. The TFF report, however, is not a disaggregation of the COT data for the financial futures markets. The traders classified into one of the four categories in the TFF report may be drawn from either the “commercial” or “noncommercial” categories of traders in the legacy COT reports

**Potential Limitations of the Data**
CFTC staff reviews the reasonableness of a trader’s classification for many of the largest traders in the markets based upon Form 40 disclosures and other information available to the Commission. As described above, the actual placement of a trader in a particular classification based upon their predominant business activity may involve some exercise of judgment on the part of Commission staff. Moreover, staff classifies traders, not their trading activity. Staff generally knows, for example, that hedge funds fall into the “leveraged funds” category, but cannot know with certainty that all of that trader’s activity is speculative. The hedge fund might be using the foreign exchange futures for hedging the currency exposure on an OTC position, for example. When staff finds the need to make a large reporting or classification change, an announcement is made and corrections are published as quickly as possible.

**IMPORTANT NOTE**: 
CFTC staff is currently working to upgrade CFTC Form 40 (large-trader identification) to improve the way large traders, their occupations and how they use U.S. futures and option markets are identified. Thus, it is likely that at the culmination of the Form 40 upgrade, the TFF report and perhaps other Commission reports may need to be altered to take advantage of the improved identification information available to us.
