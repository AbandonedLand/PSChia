
## Fetch all wallets that are loaded in chia.  This allows the CoinArray to be created.  
Function Get-WalletIDs{
    $data = (chia rpc wallet get_wallets | convertfrom-json).wallets 
    return $data
}

Function Get-AllOffers{
    $offers = (chia rpc wallet get_all_offers '{"start":0,"end":100}'| ConvertFrom-Json).trade_records
    return $offers
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


<#
    The ChiaOffer class has the following syntax:
    $offer = [ChiaOffer]::new()       - Create the class instance
    $offer.
    
    

#>





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
    $tibet_response
    $traded_coin
    $pairs

    ChiaOffer(){
        $this.max_height = 0
        $this.max_time = 0
        $this.coins = Create-CoinArray
        $this.fee = 0
        $this.offer = @{}
        $this.pairs = @{
            'DBX'='c0952d9c3761302a5545f4c04615a855396b1570be5c61bfd073392466d2a973'
            'SBX'='1a6d4f404766f984d014a3a7cab15021e258025ff50481c73ea7c48927bd28af'
            'HOA'='ad79860e5020dcdac84336a5805537cbc05f954c44caf105336226351d2902c0'
        }
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
        $this.traded_coin = $coin
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
        $this.traded_coin = $coin
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

    postToTibet(){
        $data = $this.offertext | ConvertFrom-Json
        $body = @{
            offer = $data.offer
            action = 'SWAP'
            total_donation_amount = 0
        } | ConvertTo-Json
        $contentType = 'application/json' 
        $uri = -join('https://api.v2.tibetswap.io/offer/',$this.pairs.($this.traded_coin))
        $this.tibet_response = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType $contentType

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