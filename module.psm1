Class Coin{
    [string]$coin_id


    coin([string]$coin_id){
        $this.coin_id = $coin_id
    }

    [string]split(){
        return "this is split"
    }
}

function Get-Coin {
    param(
        [string]$coin_id
    )

    Return [Coin]::new($coin_id)

}