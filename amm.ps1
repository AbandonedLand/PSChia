# App to run the AMM


<#
    Import the Wallet Functions using dot notion ( . ./script.ps1 )
#>
. ./wallet.ps1





# Fill Wallet with XCH

$coins = Invoke-WalletGetSpendableCoins -wallet_id 1
$address = 'xch1gjh6ehqk9m0mvyx4knt3j0zx09nllmech2jeq7cv2lsqgzdh2mnqc5zk2t'


$pairs = @{
    'DBX'='c0952d9c3761302a5545f4c04615a855396b1570be5c61bfd073392466d2a973'
    'SBX'='1a6d4f404766f984d014a3a7cab15021e258025ff50481c73ea7c48927bd28af'
    'HOA'='ad79860e5020dcdac84336a5805537cbc05f954c44caf105336226351d2902c0'
}

# Asset IDS from https://dexie.space/assets
$assets = @{
    DBX = 'db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20'
    SBX = 'a628c1c2c6fcb74d53746157e438e108eab5c0bb3e5c80ff9b1910b3e4832913'
    HOA = 'e816ee18ce2337c4128449bc539fbbe2ecfdd2098c4e7cab4667e223c3bdc23d'
}

Function Get-TibetSwapQuote{
    param(
        $pair_id,
        [int64]$amount_in,
        [switch]
        $xch_is_input
    )
    if($xch_is_input.IsPresent){
        $uri = -join('https://api.v2.tibetswap.io/quote/',$pair_id,'?amount_in=',$amount_in,'&xch_is_input=true')
    } else {
        $uri = -join('https://api.v2.tibetswap.io/quote/',$pair_id,'?amount_in=',$amount_in,'&xch_is_input=false')
    }

    $quote = Invoke-RestMethod -Method Get -Uri $uri
    $asset_id = ($assets.GetEnumerator() | Where-Object {$_.Value -eq $quote.asset_id}).name
    $quote | Add-Member -MemberType NoteProperty -Name asset -Value $asset_id
    if($xch_is_input.IsPresent){
        $quote | Add-Member -MemberType NoteProperty -Name xch_is_input -Value $true
    } else {
        $quote | Add-Member -MemberType NoteProperty -Name xch_is_input -Value $false
    }
    $quote
    
}

Function Submit-TibetSwapQuote{
    param (
        $quote,
        $fee
    )

    $offer = [ChiaOffer]::new()
    if($quote.xch_is_input){
        $offer.rawoffered('Chia Wallet',$quote.amount_in)
        $offer.rawrequested($quote.asset,$quote.amount_out)
    } else {
        $offer.rawoffered($quote.asset,$quote.amount_in)
        $offer.rawrequested('Chia Wallet',$quote.amount_out)
    }
    if($fee -gt 0){
        $offer.fee = $fee
    }

    $offer.createoffer()
    $offer.postToTibetSwap($pairs.($quote.asset))
    $offer.tibet_response
    
}

$uri = 'https://api.v2.tibetswap.io/quote/ad79860e5020dcdac84336a5805537cbc05f954c44caf105336226351d2902c0?amount_in=100000000000&xch_is_input=true&estimate_fee=false'
#Invoke-RestMethod -Uri $uri -Method Get
