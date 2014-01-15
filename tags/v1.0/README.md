Tired of watching the bitcoin market go **up** and **down** while you make **no** money?

Herein lies the purpose of btce_trader. It uses standard stock trader indicators like stochastic oscillators 
and moving averages to determine buy/sell points. With these indicators, btce_trader will buy and sell currencies
on the btc-e.com exchange.

The only points worth showing off is the full test-suite in t/ and the indicator interface in lib/Indicator.pm
Indicators are written in accordance with the interface specified in Indicator.pm. Ticker.pm instantiates
each indicator under lib/Indicator/. Since each indicator has the same interface, it can be swapped out at 
runtime (by setting Ticker->indicator ) in order to change behavior during different market cycles.
This also makes it very easy to integrate new indicators or indicator tests.

On the **TODO** list:
- [ ] Move sell/buy checks to a separate error checking Class
- [ ] Refactore Account.pm to use error checking Class
- [ ] Make more indicators
- [ ] Send email on buy/sells
- [ ] Use a config file to remove literals


Donate:  
btc: 1PAkGcnyhRzYhJciikWSufKtnCBnW3S4sF  
ltc: LdajBDfWTpAPjvcNY2E2Xf1TTZ242oDxzb  


  
Typical log output with 5 minute updates:    
.    
.  
.    
2014/01/09 16:19:28 Getting price for btc    
2014/01/09 16:19:29  

        Sym: btc  
        Amount: 0  
        Curr price: 834.998  
        Averages: 828.42 816.22 814.45 816.18  
        K: 41.25 D: 39.40  
        K_fast: 87.43 D_fast: 67.43  
        Total value: $0  
        Last_ac: sell  
  
2014/01/09 16:19:29 Getting price for ltc  
2014/01/09 16:19:29  

        Sym: ltc  
        Amount: 0  
        Curr price: 24  
        Averages: 23.77 23.47 23.46 23.59  
        K: 34.09 D: 32.43  
        K_fast: 73.64 D_fast: 55.70  
        Total value: $0  
        Last_ac: sell  
  
.  
.  
.  
  
  
  
**Example buy:**  
.  
.  
.  
2014/01/02 05:24:21 Getting funds from btce.  
2014/01/02 05:24:22 Buying btc at 748.656  
2014/01/02 05:24:22 Buying 0.755117 btc at 748.656. Total: $565.322872752  
2014/01/02 05:24:23 Order is on market, sleeping.  
2014/01/02 05:24:33 Order is on market, sleeping.  
2014/01/02 05:24:44 Bought 0.755117 btc for 748.656. Total: $565.322872752  
2014/01/02 05:24:44 Getting funds from btce.  
2014/01/02 05:24:44 Checking if buy order was processed correctly  
2014/01/02 05:24:44 Everything looks good, I expected $0.896796698000003 and 0.99999955 btc and I got $0.8967967 and 0.99848934  
.  
.  
.  
  
  
**Example sell:**  
  
.  
.  
.  

2014/01/11 08:04:45 Getting funds from btce.  
2014/01/11 08:04:45 Selling 0.97833841 btc at 870.601. Total: $851.74239808441  
2014/01/11 08:04:46 Order is on market, sleeping.  
2014/01/11 08:04:56 Order is on market, sleeping.  
2014/01/11 08:05:07 Sold 0.97833841 btc for 870.601. Total: $851.74239808441  
2014/01/11 08:05:07 Getting funds from btce.  
2014/01/11 08:05:08 Checking if sell order was processed correctly  
2014/01/11 08:05:08 Everything looks good, I expected $852.54431429441 and I got $850.84082949  
  
.  
.  
.  
  
Log output after changing current indicator:  
.  
.  
.  
2013/12/26 13:28:40 Indicator changed. Was Indicator::StochOsc, now is Indicator::Ma.  
.  
2014/01/01 08:00:04 Indicator changed. Was Indicator::StochOsc, now is Indicator::StochFast.  
.  
.  
.  
