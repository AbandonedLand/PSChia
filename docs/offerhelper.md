# Chia Offer Helper

## Using the helper
Load the functions into your current window.
```
cd <your PSChia Directory>
. ./offerhelper.ps1
```
Be sure to add the beginning . to the command.  This tells PowerShell to load the script into the working memory.

## Create the $offer Instance.
```
$offer = [ChiaOffer]::new()
```

Now you have the $offer object to work with.
This will help you build out the json fine needed by the Chia rpc client.  It will also work with the drivers needed to do NFT for NFT trades.

## Examples

### Trade XCH for Cat (Buy CAT)
This code will request 750 HOA and offer 0.05 XCH
Then It will post the offer to Dexie


```
# Create the offer
$offer = [ChiaOffer]::new()

# the coin name is the same as what shows in your wallet.
$offer.requested('HOA',750)

# when requesting or offering XCH, use the offerxch or requestxch methods.  It will convert XCH to mojos correctly.
$offer.offerxch(0.05)

# This creates the offer
$offer.createoffer()

# Uploads this offer to dexie
$offer.postToDexie()
```

### Trade XCH for Cat with Time Limit of 60 minutes (Buy CAT)
While the offer is only good for a limited time, the chia wallet will not automatically free up your coins at the end of the offer.  You'll want to run the Clear-ExpiredOffers function from the ./grid.ps1 functions to clean it out.

```
$offer = [ChiaOffer]::new()
$offer.requested('HOA',750)
$offer.offerxch(0.05)
$offer.addTimeInMinutes(60)
$offer.createoffer()
$offer.postToDexie()
```

### Trade Cat for XCH (Sell CAT)
Make sure when using XCH as request or offer, you use the XCH methods indead of the CAT methods or the calculations will be off.

```
$offer = [ChiaOffer]::new()
$offer.requestxch(0.05)
$offer.offered('HOA',750)
$offer.createoffer()
$offer.postToDexie()
```

### Create XCH for NFT trade (Buy NFT)
Requesting an NFT requires you to add a Driver to the JSON file. This code does it automatically.
```
$offer = [ChiaOffer]::new()
$offer.requestednft('nft1r7h8s3vnw7gtdezgcm9qakj3fctug4745s72ymdf3ul03nzd4pvqkrpdc4')
$offer.offerxch(0.75)
$offer.createoffer()
$offer.postToDexie()
```


## [ChiaOffer] Methods

### offererednft($nft_id)
Adds the NFT to your offer by using your Chia Wallet to get the launcher ID

### offerednftmg($nft_id)
Same as offerednft but uses mintgarden to get the nft launcher

### requestednft($nft_id)
Adds the requsted nft to your offer builder.  Also adds any driver information used in calculating royalties.

### requested($coin, $amount)
Requests a CAT by $coin(the name of the coin in your wallet) and $amount (full coin amount - NOT MOJO)

### offerxch($amount)
Adds the XCH amount (full coin - NOT MOJO) to Offer Builder

### offered($coin, $amount)
Offers a CAT by $coin(the name of coin in your wallet) and $amount (full coin amount - NOT MOJO)

### makejson()
Used to make the json file required by the wallet rpc endpoint.

### addBlocks($num)
Add a max block heigh to your offer.  It will only be valid for the next $num blocks.  This method requires you to run a full node.

### addTimeInMinutes($min)
Adds a max time to your offers.  It will only be valid for the next ($min) minutes.  This method can be done with just the wallet node.

### createoffer()
Creates the offer with the chia client

### postToDexie()
Submits your offer to dexie