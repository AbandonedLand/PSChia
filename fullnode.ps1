
Function Get-AdditionsAndRemovals{
    param(
        [Parameter(Mandatory=$true)]
        $header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    return  chia rpc full_node get_additions_and_removals $json | ConvertFrom-Json
}

Function Get-AllMempoolItems{
    return chia rpc full_node get_all_mempool_items | ConvertFrom-Json
}

Function Get-AllMempoolTxIds{
    return chia rpc full_node get_all_mempool_tx_ids | ConvertFrom-Json
}

Function Get-Block{
    param(
        [Parameter(Mandatory=$true)]
        $header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    return  chia rpc full_node get_block $json | ConvertFrom-Json
}

Function Get-BlockChainState{
    return chia rpc full_node get_blockchain_state | ConvertFrom-Json
}

Function Get-Blocks{
    param(
        [Parameter(Mandatory=$true)]
        $start,
        [Parameter(Mandatory=$true)]
        $end,
        [switch]
        $exclude_header_hash,
        [switch]
        $exclude_reorged
    )
    $json = @{
        'start'=$start;
        'end'=$end
    } 
    if($exclude_header_hash.IsPresent){
        $json.Add('exclude_header_hash',$true)
    }
    if($exclude_reorged.IsPresent){
        $json.Add('exclude_reorged',$true)
    }

    $json = $json | ConvertTo-Json

    return chia rpc full_node get_block_records $json | ConvertFrom-Json    
}

Function Get-BlockCountMetrics{

    return  chia rpc full_node get_block_count_metrics | ConvertFrom-Json
}

Function Get-BlockRecord{
    param(
        [Parameter(Mandatory=$true)]
        $header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    return  chia rpc full_node get_block_record $json | ConvertFrom-Json
}

Function Get-BlockRecords{
    param(
        [Parameter(Mandatory=$true)]
        [Int64]$start,
        [Parameter(Mandatory=$true)]
        [Int64]$end
    )
    $json = @{
        'start'=$start;
        'end'=$end
    } | ConvertTo-Json

    return chia rpc full_node get_block_records $json | ConvertFrom-Json    
}

Function Get-BlockRecordByHeight{
    param(
        [Parameter(Mandatory=$true)]
        $height
    )
    $json = @{
        'height'=$height
    } | ConvertTo-Json

    return chia rpc full_node get_block_record_by_height $json | ConvertFrom-Json    
}

Function Get-BlockSpends{
    param(
        [Parameter(Mandatory=$true)]
        $header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    return  chia rpc full_node get_block_spends $json | ConvertFrom-Json
}

Function Get-CoinRecordsByHint{
    param(
        [Parameter(Mandatory=$true)]
        $hint,
        $start_height,
        $end_height,
        [switch]
        $include_spent_coins
    )

    $json = @{
        'hint'=$hint;
        'include_spent_coins'=$include_spent_coins
    }

    if($start_height){
        $json.Add('start_height',$start_height)
    }
    if($end_height){
        $json.Add('end_height',$end_height)
    }
    if($include_spent_coins.IsPresent){
        $json.Add('include_spent_coins',$true)
    }

    $json = $json | ConvertTo-Json

    return  chia rpc full_node get_coin_records_by_hint $json | ConvertFrom-Json
}

Function Get-CoinRecordsByNames{
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$names,
        $start_height,
        $end_height,
        [switch]
        $include_spent_coins
    )

    $json = @{
        'names'=$names;
        'include_spent_coins'=$include_spent_coins
    }

    if($start_height){
        $json.Add('start_height',$start_height)
    }
    if($end_height){
        $json.Add('end_height',$end_height)
    }
    if($include_spent_coins.IsPresent){
        $json.Add('include_spent_coins',$true)
    }

    $json = $json | ConvertTo-Json

    return  chia rpc full_node get_coin_records_by_names $json | ConvertFrom-Json
}


Function Get-CoinRecordByParentIds{
    param(
        [Parameter(Mandatory=$true)]
        $parent_ids,
        $start_height,
        $end_height,
        [switch]
        $include_spent_coins
    )
    
    $json = @{
        'parent_ids'=$parent_ids
    } 

    if($start_height){
        $json.Add('start_height',$start_height)
    }
    if($end_height){
        $json.Add('end_height',$end_height)
    }
    if($include_spent_coins.IsPresent){
        $json.Add('include_spent_coins',$true)
    }

    $json = $json | ConvertTo-Json

    return  chia rpc full_node get_coin_records_by_parent_ids $json | ConvertFrom-Json
}

Function Get-CoinRecordByPuzzleHash{
    param(
        [Parameter(Mandatory=$true)]
        $puzzle_hash,
        $start_height,
        $end_height,
        [switch]
        $include_spent_coins
    )
    
    $json = @{
        'puzzle_hash'=$puzzle_hash
    } 

    if($start_height){
        $json.Add('start_height',$start_height)
    }
    if($end_height){
        $json.Add('end_height',$end_height)
    }
    if($include_spent_coins.IsPresent){
        $json.Add('include_spent_coins',$true)
    }

    $json = $json | ConvertTo-Json
    

    return  chia rpc full_node get_coin_records_by_puzzle_hash $json | ConvertFrom-Json
}

Function Get-CoinRecordsByPuzzleHashes{
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$puzzle_hashes,
        $start_height,
        $end_height,
        [switch]
        $include_spent_coins
    )
    
    $json = @{
        'puzzle_hashes'=$puzzle_hashes
    } 

    if($start_height){
        $json.Add('start_height',$start_height)
    }
    if($end_height){
        $json.Add('end_height',$end_height)
    }
    if($include_spent_coins.IsPresent){
        $json.Add('include_spent_coins',$true)
    }

    $json = $json | ConvertTo-Json
    

    return  chia rpc full_node get_coin_records_by_puzzle_hashes $json | ConvertFrom-Json
}

Function Get-CoinRecordByName{
    param(
        [Parameter(Mandatory=$true)]
        $name
    )
    $json = @{
        'name'=$name
    } | ConvertTo-Json

    return  chia rpc full_node get_coin_record_by_name $json | ConvertFrom-Json
}

Function Get-FeeEstimate{
    param(
        [parameter(Mandatory=$true,ParameterSetName="WithSpend")]
        [string]$spend_bundle,
        [parameter(Mandatory=$true,ParameterSetName="WithCost")]
        [Int64]$cost,
        [int64[]]$target_times
    )

    $json = @{}
    if($spend_bundle){
        $json.Add('spend_bundle',$spend_bundle)
    }
    if($cost){
        $json.Add('cost',$cost)
    }
    if($target_times){
        $json.Add('target_times',$target_times)
    }
    $json = $json | ConvertTo-Json

    return chia rpc full_node get_fee_estimate $json | ConvertFrom-Json

}

Function Get-MempoolItemByTxId{
    param(
        [Parameter(Mandatory=$true)]
        [string]$tx_id
    )

    $json = @{
        'tx_id'=$tx_id;
    } | ConvertTo-Json

    return  chia rpc full_node get_mempool_item_by_tx_id $json | ConvertFrom-Json
}

Function Get-NetworkInfo{
  
    return  chia rpc full_node get_network_info | ConvertFrom-Json
}

Function Get-NetworkSpace{
    param(
        [Parameter(Mandatory=$true)]
        [string]$older_block_header_hash,
        [Parameter(Mandatory=$true)]
        [string]$newer_block_header_hash
    )

    $json = @{
        'older_block_header_hash'=$older_block_header_hash;
        'newer_block_header_hash'=$newer_block_header_hash
    } | ConvertTo-Json

    return  chia rpc full_node get_network_space $json | ConvertFrom-Json
}

Function Get-PuzzleAndSolution{
    param(
        [Parameter(Mandatory=$true)]
        $coin_id,
        [Parameter(Mandatory=$true)]
        $height
    )

    $json = @{
        'coin_id'=$coin_id;
        'height'=$height
    } | ConvertTo-Json

    return chia rpc full_node get_puzzle_and_solution $json | ConvertFrom-Json
}

Function Get-RecentSignagePointOrEOS{
    param(
        [parameter(Mandatory=$true,ParameterSetName="WithSPHash")]
        $sp_hash,
        [parameter(Mandatory=$true,ParameterSetName="WithChallengeHash")]
        $challenge_hash
    )

    $json = @{} 
    if($sp_hash){
        $json.Add('sp_hash',$sp_hash)
    }
    if($challenge_hash){
        $json.Add('challenge_hash',$challenge_hash)
    }
    $json = $json | ConvertTo-Json

    return  chia rpc full_node get_recent_signage_point_or_eos $json | ConvertFrom-Json
}

Function Get-Routes{
  
    return  chia rpc full_node get_routes | ConvertFrom-Json
}

Function Get-UnfinishedBlockHeaders{

    return  chia rpc full_node get_unfinished_block_headers | ConvertFrom-Json
}

Function Invoke-healthz{
    return chia rpc full_node healthz
}

Function Invoke-PushTx{
    param(
        [Parameter(Mandatory=$true)]
        [string]$spend_bundle
    )

    return chia rpc full_node push_tx $spend_bundle | ConvertFrom-Json


}
