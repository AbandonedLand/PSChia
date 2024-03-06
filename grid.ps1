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


# This class is used to build and submit offers.
Class ChiaOffer{
    [hashtable]$offer
    $coins
    $fee
    $offertext
    $json
    $dexie_response
    $dexie_url 
    $requested_nft_data
    $nft_info
    $max_height
    $max_time


    ChiaOffer(){
        $this.max_height = 0
        $this.max_time = 0
        $this.coins = Create-CoinArray
        $this.fee = 0
        $this.offer = @{}
        
        $this.dexie_url = "https://dexie.space/v1/offers"
    }

    setTestNet(){
        $this.dexie_url = "https://api-testnet.dexie.space/v1/offers"
    }

    offerednft($nft_id){
        $data = $this.RPCNFTInfo($nft_id)
        $this.offer.($this.nft_info.launcher_id.substring(2))=-1
    }

    offerednftmg($nft_id){
    
        $uri = -join('https://api.mintgarden.io/nfts/',$nft_id)
        $data = Invoke-RestMethod -Method Get -Uri $uri
        $this.offer.($data.id)=-1
    }

    requestednft($nft_id){
        $this.RPCNFTInfo($nft_id)
        $this.offer.($this.nft_info.launcher_id.substring(2))=1
        $this.BuildDriverDict($this.nft_info)
    }

    requested($coin, $amount){
        $this.offer.([string]$this.coins.$coin.id)=($amount*1000)
    }

    addBlocks($num){
        $this.max_height = (((chia rpc full_node get_blockchain_state) | convertfrom-json).blockchain_state.peak.height) + $num
    }

    addTimeInMinutes($min){
        $DateTime = (Get-Date).ToUniversalTime()
        $DateTime = $DateTime.AddMinutes($min)
        $this.max_time = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
    }

    requestxch($Amount){
        $coin = 'Chia Wallet'
        $this.offer.([string]$this.coins.$coin.id)=([int64]($amount*1000000000000))
        
    }
 

    offerxch($Amount){
        $coin = 'Chia Wallet'
        $this.offer.([string]$this.coins.$coin.id)=([int64]($amount*-1000000000000))
        
    }

    offered($coin, $amount){
        $this.offer.([string]$this.coins.$coin.id)=([int64]($amount*-1000))
    }
    
    makejson(){
        if($global:PSVersionTable.PSVersion.Major -ge 7 -AND $global:PSVersionTable.PSVersion.Minor -ge 3){
            if($this.max_time -ne 0){
                $this.json = ([ordered]@{"offer"=($this.offer); "fee"=$this.fee;"driver_dict"=$this.requested_nft_data;"max_time"=$this.max_time} | convertto-json -Depth 11)        
            }else{
                $this.json = ([ordered]@{"offer"=($this.offer); "fee"=$this.fee;"driver_dict"=$this.requested_nft_data} | convertto-json -Depth 11)     
            }
            
        }
        else{
            if($this.max_time -ne 0){
                $this.json = ([ordered]@{"offer"=($this.offer); "fee"=$this.fee;"driver_dict"=$this.requested_nft_data;"max_time"=$this.max_time} | convertto-json -Depth 11)
            } else {
                $this.json = ([ordered]@{"offer"=($this.offer); "fee"=$this.fee;"driver_dict"=$this.requested_nft_data} | convertto-json -Depth 11 )
            }
        }
    }

    createoffer(){
        $this.makejson()
        $this.offertext = chia rpc wallet create_offer_for_ids $this.json
    }

    createofferwithoutjson(){
        $this.offertext = chia rpc wallet create_offer_for_ids $this.json
    }
    
    postToDexie(){
        $data = $this.offertext | convertfrom-json
        $body = @{
            "offer" = $data.offer
        }
        $contentType = 'application/json' 
        $json_offer = $body | convertto-json
        $this.dexie_response = Invoke-WebRequest -Method POST -body $json_offer -Uri $this.dexie_url -ContentType $contentType
    }

    RPCNFTInfo($nft_id){
        $this.nft_info = (chia rpc wallet nft_get_info ([ordered]@{coin_id=$nft_id} | ConvertTo-Json) | Convertfrom-json).nft_info
    }

    BuildDriverDict($data){
    
        $this.requested_nft_data = [ordered]@{($data.launcher_id.substring(2))=[ordered]@{
                    type='singleton';
                    launcher_id=$data.launcher_id;
                    launcher_ph=$data.launcher_puzhash;
                    also=[ordered]@{
                        type='metadata';
                        metadata=$data.chain_info;
                        updater_hash=$data.updater_puzhash;
                        also=[ordered]@{
                            type='ownership';
                            owner=$data.owner_did;
                            transfer_program=[ordered]@{
                                type='royalty transfer program';
                                launcher_id=$data.launcher_id;
                                royalty_address=$data.royalty_puzzle_hash;
                                royalty_percentage=[string]$data.royalty_percentage
                            }
                        }
                    }
                }
            }
        
    }

}

$pairs = @{
    'DBX'='c0952d9c3761302a5545f4c04615a855396b1570be5c61bfd073392466d2a973'
    'SBX'='1a6d4f404766f984d014a3a7cab15021e258025ff50481c73ea7c48927bd28af'
    'HOA'='ad79860e5020dcdac84336a5805537cbc05f954c44caf105336226351d2902c0'
}

$cats = @{
    'DBX'=''
}




##  Easy Rounding function instead of useing [Math]::round
Function round($number){
    return [Math]::round($number)
}

## Fetch all wallets that are loaded in chia.  This allows the CoinArray to be created.  
Function Get-WalletIDs{
    $data = (chia rpc wallet get_wallets | convertfrom-json).wallets 
    return $data
}


## The Coin Array makes it easier to find the Wallet ID of your token.  In the offer api, you need wallet IDs.
## This lets you use the token name instead of the wallet ID.
function Create-CoinArray{
    $data = Get-WalletIDs
    #Create holding place for wallet data.
    $coins = @{}
    foreach($item in $data){
        $coins.($item.name) =@{}
        $coins.($item.name).id = $item.id
    }
    return $coins

} 

# Pull data from tibetswap to establish the current state of the pool assets.

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

Function Add-TokenToPool{
    param(
        $pool_data,
        [int64]$amount,
        $fee_percentage
    )
    $k = $pool_data.token_reserve * $pool_data.xch_reserve
    $amount = $amount*1000
    $tmpToken = $pool_data.token_reserve + $amount
    $offerXch = ($k / $tmpToken) - $pool_data.xch_reserve
    $tmpfee = $offerXch * (-1 * $fee_percentage)
    $offerXch = round($offerXch + $tmpfee)
    return [ordered]@{'XCH'=($offerXch/1000000000000);'fee'=($tmpfee/1000000000000);"token"=$amount}
}

Function Create-TradingArrayForLauncherId{
    param(
        $coin,
        $xch_max,
        $xch_steps
    )
    
    $launcher_id = $pairs.$coin
    $launcher_id
    $table=@{}
    $table.coin = $coin
    $table.buy = @()
    $table.sell = @()
    $pool_data = Get-PoolAssetsForId($launcher_id)

    if($xch_max -ge $xch_steps){
        $min = 1
        $max = [Math]::Floor($xch_max / $xch_steps)
        $range = $min .. $max
        foreach($step in $range){
            $xch = $step*$xch_steps
            $buy = (Remove-XCHFromPool -pool_data $pool_data -amount $xch -fee_percentage 0.006 )
            if($step -gt 1){
                $buy.XCH = [math]::round(($xch_steps + ([decimal](($step-1)/1000000000000))),12)
                $last_step = $step - 1
                $buy.tokens = $buy.tokens - (($table.buy[0..$last_step].tokens | Measure-Object -Sum).Sum)
            }
            $table.buy += $buy
            $sell = (Add-XchToPool -pool_data $pool_data -amount $xch -fee_percentage 0.006 )
            if($step -gt 1){
                $sell.XCH = [math]::round(($xch_steps + ([decimal](($step-1)/1000000000000))),12)
                $last_step = $step - 1
                $sell.tokens = ($sell.tokens - ($table.sell[0..$last_step].tokens | Measure-Object -Sum).Sum)
            }
            $table.sell += $sell
        }
    }

    


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
        $max_time 
    )

    $bundle = @()
    # TODO: Validate enough tokens

    foreach($buy in $trading_array.buy){
        $text = -join("Buy - ",$buy.tokens," ", $trading_array.coin," for ",$buy.XCH, " XCH")
        Write-Output $text
        $offer = [ChiaOffer]::new()
        $offer.offerxch($buy.XCH)
        $offer.requested($trading_array.coin,$buy.tokens)
        $offer.addTimeInMinutes($max_time)
        $offer.createoffer()
        $bundle += ($offer.offertext | ConvertFrom-Json)
        $offer.postToDexie()
        
        
        
    }
    foreach($sell in $trading_array.sell){
        $text = -join("Sell - ",$sell.tokens," ", $trading_array.coin," for ",$sell.XCH, " XCH")
        Write-Output $text
        $offer = [ChiaOffer]::new()
        $sell.tokens = $sell.tokens * -1
        $offer.offered($trading_array.coin,$sell.tokens)
        $offer.requestxch($sell.XCH)
        $offer.addTimeInMinutes($max_time)
        $offer.createoffer()
        $bundle += ($offer.offertext | ConvertFrom-Json)
        $offer.postToDexie()
        

    }
        
    return $bundle

}


Function Start-TradeForCoin{
    param(
        $coin,
        $xch_max,
        $xch_steps,
        $max_time
    )
    Clear-ExpiredOffers
    $data = Create-TradingArrayForLauncherId -coin $coin -xch_max $xch_max -xch_steps $xch_steps
    $data
    $bundle = Create-OffersForTradingArray -trading_array $data -max_time $max_time
    $bundle
}
