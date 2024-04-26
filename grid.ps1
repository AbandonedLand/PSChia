# First Draft of an AMM.  
# It's not pretty, but it works-ish.
# DON'T USE This unless you know read through and understand what it does.   you may lose money!
# Trading pair launcher IDs on TibetSwap.  
# The full list can be pulled from the API: https://api.v2.tibetswap.io/pairs?skip=0&limit=10
# Docs: https://api.v2.tibetswap.io/docs#/default/read_pairs_pairs_get

<#


RUN::

Start-TradeForCoin -Coin HOA -xch_max 1 -xch_step 0.20 -max_time 60

. this will create 5 buy and 5 sell transactions for HOA coin for 0.2 XCH each and base the pricing off TibetSwap's current pricing.
. Assuming you have a Coin in your Wallet called HOA 
. Supported Coins are HOA / SBX / DBX


#>


<#
    This file contains a helper function that will create offers.
#>
. ./offerhelper.ps1


# fee_charged is used to determine the spread between buy and sell offers.  To keep competative against tibetswap, you need to offer less than 0.007 (0.07%)

$fee_charged = 0.006

# Default number of minutes in an offer
$offer_length = 60



# CAT Asset IDs
# You can get the coin asset_id from https://dexie.space/assets
$cats = @{
    'DBX'='db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20'
    'SBX'='a628c1c2c6fcb74d53746157e438e108eab5c0bb3e5c80ff9b1910b3e4832913'
    'HOA'='e816ee18ce2337c4128449bc539fbbe2ecfdd2098c4e7cab4667e223c3bdc23d'
}


# Trading pairs launcher_id for TibetSwap
# You can pull the launcher_id from https://api.v2.tibetswap.io/token/{asset_id}
$pairs = @{
    'DBX'='c0952d9c3761302a5545f4c04615a855396b1570be5c61bfd073392466d2a973'
    'SBX'='1a6d4f404766f984d014a3a7cab15021e258025ff50481c73ea7c48927bd28af'
    'HOA'='ad79860e5020dcdac84336a5805537cbc05f954c44caf105336226351d2902c0'
}


##  Easy Rounding function instead of useing [Math]::round
Function round($number){
    return [Math]::round($number)
}


# Pull token reserve data from tibetswap to establish the current state of the pool assets.

Function Get-PoolAssetsForId{
    param(
        $launcher_id
    )
    $uri = -join(' https://api.v2.tibetswap.io/pair/',$launcher_id)
    $uri
    $data = Invoke-RestMethod -uri $uri
    return $data
}

# Get a quote for how many tokens are given out if you add XCH to the Pool.  
# XCH is in full XCH notation and not mojos.
Function Add-XchToPool{
    param(
        $pool_data,
        [decimal]$amount,
        $fee_percentage
    )
    # Find the constant product of the AMM (A*B=K)
    $k = $pool_data.token_reserve * $pool_data.xch_reserve
    
    # Convert XCH to Mojos
    $amount = $amount * 1000000000000
    
    # Add the XCH to the current Pool xch_reserve
    $tmpXch = $pool_data.xch_reserve + $amount
    
    # Calculate how many tokens should be in the pool, then subtract it from what it has to find the amount of tokens to offer
    $offerTokens = ($k / $tmpXch) - $pool_data.token_reserve
    
    # Calculate fee from the offered tokens
    $tmpfee = $offerTokens * (-1 * $fee_percentage)
    
    # Calculate what will be offered after fee.
    $offerTokens = round($offerTokens + $tmpfee)

    #return an array of this information that can be used to create offers.
    return [ordered]@{"tokens"=$offerTokens/1000;"fee"=($tmpfee/1000);"XCH"=($amount/1000000000000)}
}

# Get a quote for how many tokens to receive if you remove XCH from the pool.
Function Remove-XCHFromPool{
    param(
        #Expects input from Get-PoolAssetsForId
        $pool_data,
        [decimal]$amount,
        $fee_percentage
    )
    # Find the constant product of the AMM (A*B=K)
    $k = $pool_data.token_reserve * $pool_data.xch_reserve
    
    # Convert XCH to Mojos
    $amount = $amount * 1000000000000
    
    # Remove the XCH to the current Pool xch_reserve
    $tmpXch = $pool_data.xch_reserve - $amount
    
    # Calculate how many tokens should be in the pool, then subtract it from what it has to find the amount of tokens to offer
    $offerTokens = ($k / $tmpXch) - $pool_data.token_reserve
    
    # Calculate fee from the offered tokens
    $tmpfee = $offerTokens * (-1 * $fee_percentage)
    
    # Calculate what will be offered after fee.
    $offerTokens = round($offerTokens - $tmpfee)
    
    #return an array of this information that can be used to create offers.
    return [ordered]@{"tokens"=$offerTokens/1000;"fee"=($tmpfee/1000);"XCH"=($amount/1000000000000)}
}

# Calculate the new pool totals if you add CATs to the pool
Function Add-TokenToPool{
    param(
        $pool_data,
        [int64]$amount,
        $fee_percentage
    )
    # Find the constant product of the AMM (A*B=K)
    $k = $pool_data.token_reserve * $pool_data.xch_reserve

    # Convert CAT to Mojos
    $amount = $amount*1000

    # Add the CAT to the current Pool xch_reserve
    $tmpToken = $pool_data.token_reserve + $amount

    # Calculate how much XCH should be in the pool, then subtract it from what it has to find the amount of XCH to offer
    $offerXch = ($k / $tmpToken) - $pool_data.xch_reserve

    # Calculate fee from the offered tokens
    $tmpfee = $offerXch * (-1 * $fee_percentage)

    # Calculate what will be offered after fee.
    $offerXch = round($offerXch + $tmpfee)

    #return an array of this information that can be used to create offers.
    return [ordered]@{'XCH'=($offerXch/1000000000000);'fee'=($tmpfee/1000000000000);"token"=$amount}
}



# This will build out the array of offer data needed to create all the offers.
# Coin is the coin you wish to trade.
# xch_max is how much XCH in total you want to trade with on each side of the offer.
# xch_steps is the size of offers you wish to create.   

# Example: Create-TradingArrayForLauncherID -coin HOA -xch_max 4 -xch_stpes 1
# -- This will create 4 offers to buy and 4 offers to sell 1 XCH worth of HOA using the constant product model

Function Create-TradingArrayForLauncherId{
    param(
        $coin,
        $xch_max,
        $xch_steps
    )
    
    # Find the launcher ID from the Friendly Coin Name
    $launcher_id = $pairs.$coin
    
    # Make a placeholder table to hold offer/request amounts for the purchase and sell of token.
    $table=@{}
    $table.coin = $coin
    $table.buy = @()
    $table.sell = @()
    
    # Get the current assets in TibetSwap for the pair
    $pool_data = Get-PoolAssetsForId($launcher_id)

    # error checking to make sure the step size is not larger than the maximum xch.
    if($xch_max -ge $xch_steps){
        
        # Setting the minimum number of offers
        $min = 1
        # Set the max number of offers.  Making sure no wierd amount of offers are created.
        $max = [Math]::Floor($xch_max / $xch_steps)

        # Create array that increments up to the maximum number of steps
        $range = $min .. $max

        foreach($step in $range){
            # Calculate how much XCH will be added or removed from the pool.  Used to calculate how many CAT tokens to request/offer.
            $xch = $step*$xch_steps

            # Calculate what the pool looks like after xch removal
            $buy = (Remove-XCHFromPool -pool_data $pool_data -amount $xch -fee_percentage $fee_charged )

            # Counting the steps
            if($step -gt 1){
                # Get the amount of xch in mojos needed then convert to XCH notation.
                $buy.XCH = [math]::round(($xch_steps + ([decimal](($step-1)/1000000000000))),12)

                # Count Down the steps
                $last_step = $step - 1

                # Add result to table.
                $buy.tokens = $buy.tokens - (($table.buy[0..$last_step].tokens | Measure-Object -Sum).Sum)
            }

            # Add to buy table
            $table.buy += $buy

            # Calculate what the pool looks like after xch addition
            $sell = (Add-XchToPool -pool_data $pool_data -amount $xch -fee_percentage $fee_charged )

            # Counting the steps
            if($step -gt 1){
                # Get the amount of xch in mojos needed then convert to XCH notation.
                $sell.XCH = [math]::round(($xch_steps + ([decimal](($step-1)/1000000000000))),12)

                # Count Down the steps
                $last_step = $step - 1

                 # Add result to table.
                $sell.tokens = ($sell.tokens - ($table.sell[0..$last_step].tokens | Measure-Object -Sum).Sum)
            }
            # Add to sell table
            $table.sell += $sell
        }
    }

    # Return the results of all calculations.
    return $table

}

Function Clear-ExpiredOffers{
    Write-Host "Clearing Old Offers"
    $DateTime = (Get-Date).ToUniversalTime()
    $timestamp = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
    $offers = Get-AllOffers
    $offers = $offers | Where-Object {$_.valid_times.max_time -le $timestamp}
    
    foreach($offer in $offers){
        Cancel-Offer -trade_id $offer.trade_id
    }
    
}





function Cancel-Offer {
    param (
        $trade_id,
        [switch]
        $secure
    )
    $onchain=$false
    if($secure.IsPresent){
        $onchain=$true;
    }
    $json = @{
        'trade_id'=$trade_id;
        'secure'=$onchain
    } | ConvertTo-Json

    return (chia rpc wallet cancel_offer $json) | ConvertFrom-Json
    
}


Function Create-OffersForTradingArray{
    param(
        # Input from Create-TradingArrayForLauncherId
        $trading_array,
        # Input Time in Minutes
        $max_time
    )


    # Set default lenth of time
    if(-NOT $max_time.IsPresent){
        $max_time = $offer_length
    }

    $bundle = @()
    

    foreach($buy in $trading_array.buy){
        # Build output for screen
        $text = -join("Buy - ",$buy.tokens," ", $trading_array.coin," for ",$buy.XCH, " XCH")

        # Show output on screen
        Write-Output $text

        # Create an offer instance
        $offer = [ChiaOffer]::new()

        # Offer XCH
        $offer.offerxch($buy.XCH)

        # Request CAT
        $offer.requested($trading_array.coin,$buy.tokens)

        # Add max Time
        $offer.addTimeInMinutes($max_time)

        # Create Offer
        $offer.createoffer()

        # Add info to Bundle variable
        $bundle += ($offer.offertext | ConvertFrom-Json)

        # Post to Dexie
        $offer.postToDexie()
    }
    foreach($sell in $trading_array.sell){
        # Build output for screen
        $text = -join("Sell - ",$sell.tokens," ", $trading_array.coin," for ",$sell.XCH, " XCH")

        # Show output on screen
        Write-Output $text

        # Create an offer instance
        $offer = [ChiaOffer]::new()

        # Make the tokens negative for RPC
        $sell.tokens = $sell.tokens * -1

        # Offer CAT
        $offer.offered($trading_array.coin,$sell.tokens)

        # Request XCH
        $offer.requestxch($sell.XCH)

        # Add max time
        $offer.addTimeInMinutes($max_time)

        # Create Offer
        $offer.createoffer()

        # Add to bundle variable
        $bundle += ($offer.offertext | ConvertFrom-Json)

        # Post to dexie
        $offer.postToDexie()
        

    }
        
    # Output the bundle to screen
    return $bundle

}



# Easy function for clearning old offers and creating new ones.
<#
If you wish to run this every 60 minutes you can do something like this

while($true){
    Start-TradeForCoin -coin HOA -xch_max 4 -xch_steps 1 -max_time 60
    # Start-Sleep takes times in seconds.  I'm adding on an extra 30 seconds to give the process time to make sure everything is set.
    Start-Sleep ((60*60)+30)
}

#>


Function Start-TradeForCoin{
    param(
        $coin,
        $xch_max,
        $xch_steps,
        $max_time
    )
    # Clear Out Old Offers
    Clear-ExpiredOffers

    # Create the trading data array
    $data = Create-TradingArrayForLauncherId -coin $coin -xch_max $xch_max -xch_steps $xch_steps
    
    # Create the offers for trading data.
    Create-OffersForTradingArray -trading_array $data -max_time $max_time
    
}

