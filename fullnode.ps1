
Function Invoke-FullNodeGetAdditionsAndRemovals {
    param(
        [Parameter(Mandatory=$true)]
        [string]$header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    chia rpc full_node get_additions_and_removals $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetAllMempoolItems{
    chia rpc full_node get_all_mempool_items | ConvertFrom-Json
}

Function Invoke-FullNodeGetAllMempoolTxIds{
    chia rpc full_node get_all_mempool_tx_ids | ConvertFrom-Json
}

Function Invoke-FullNodeGetBlock{
    param(
        [Parameter(Mandatory=$true)]
        [string]$header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    chia rpc full_node get_block $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetBlockChainState{
    chia rpc full_node get_blockchain_state | ConvertFrom-Json
}

Function Invoke-FullNodeGetBlocks{
    param(
        [Parameter(Mandatory=$true)]
        [int64]$start,
        [Parameter(Mandatory=$true)]
        [int64]$end,
        [switch]
        $exclude_header_hash,
        [switch]
        $exclude_reorged
    )
    $json = @{
        'start'=$start
        'end'=$end
    } 
    if($exclude_header_hash.IsPresent){
        $json.Add('exclude_header_hash',$true)
    }
    if($exclude_reorged.IsPresent){
        $json.Add('exclude_reorged',$true)
    }

    $json = $json | ConvertTo-Json

    chia rpc full_node get_block_records $json | ConvertFrom-Json    
}

Function Invoke-FullNodeGetBlockCountMetrics{

    chia rpc full_node get_block_count_metrics | ConvertFrom-Json
}

Function Invoke-FullNodeGetBlockRecord{
    param(
        [Parameter(Mandatory=$true)]
        [string]$header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    chia rpc full_node get_block_record $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetBlockRecords{
    param(
        [Parameter(Mandatory=$true)]
        [Int64]$start,
        [Parameter(Mandatory=$true)]
        [Int64]$end
    )
    $json = @{
        'start'=$start
        'end'=$end
    } | ConvertTo-Json

    chia rpc full_node get_block_records $json | ConvertFrom-Json    
}

Function Invoke-FullNodeGetBlockRecordByHeight{
    param(
        [Parameter(Mandatory=$true)]
        [int64]$height
    )
    $json = @{
        'height'=$height
    } | ConvertTo-Json

    chia rpc full_node get_block_record_by_height $json | ConvertFrom-Json    
}

Function Invoke-FullNodeGetBlockSpends{
    param(
        [Parameter(Mandatory=$true)]
        [string]$header_hash
    )
    $json = @{
        'header_hash'=$header_hash
    } | ConvertTo-Json

    chia rpc full_node get_block_spends $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetCoinRecordsByHint{
    param(
        [Parameter(Mandatory=$true)]
        [string]$hint,
        [int64]$start_height,
        [int64]$end_height,
        [switch]
        $include_spent_coins
    )

    $json = @{
        'hint'=$hint
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

    chia rpc full_node get_coin_records_by_hint $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetCoinRecordsByNames{
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$names,
        [int64]$start_height,
        [int64]$end_height,
        [switch]
        $include_spent_coins
    )

    $json = @{
        'names'=$names
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

    chia rpc full_node get_coin_records_by_names $json | ConvertFrom-Json
}


Function Invoke-FullNodeGetCoinRecordByParentIds{
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$parent_ids,
        [int64]$start_height,
        [int64]$end_height,
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

    chia rpc full_node get_coin_records_by_parent_ids $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetCoinRecordByPuzzleHash{
    param(
        [Parameter(Mandatory=$true)]
        [string]$puzzle_hash,
        [int64]$start_height,
        [int64]$end_height,
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
    

    chia rpc full_node get_coin_records_by_puzzle_hash $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetCoinRecordsByPuzzleHashes{
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$puzzle_hashes,
        [int64]$start_height,
        [int64]$end_height,
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
    

    chia rpc full_node get_coin_records_by_puzzle_hashes $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetCoinRecordByName{
    param(
        [Parameter(Mandatory=$true)]
        [string]$name
    )
    $json = @{
        'name'=$name
    } | ConvertTo-Json

    chia rpc full_node get_coin_record_by_name $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetFeeEstimate{
    param(
        [parameter(Mandatory=$true,ParameterSetName="WithSpend")]
        $spend_bundle,
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
    $json = $json | ConvertTo-Json -Depth 10
    $json

    chia rpc full_node get_fee_estimate $json | ConvertFrom-Json

}

Function Invoke-FullNodeGetMempoolItemByTxId{
    param(
        [Parameter(Mandatory=$true)]
        [string]$tx_id
    )

    $json = @{
        'tx_id'=$tx_id;
    } | ConvertTo-Json

    chia rpc full_node get_mempool_item_by_tx_id $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetMempoolItemsByCoinName{
    param(
        [Parameter(Mandatory=$true)]
        [string]$coin_name
    )

    $json =@{
        'coin_name'=$coin_name
    } | ConvertTo-Json

    chia rpc full_node get_mempool_items_by_coin_name $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetNetworkInfo{
  
    chia rpc full_node get_network_info | ConvertFrom-Json
}

Function Invoke-FullNodeGetNetworkSpace{
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

    chia rpc full_node get_network_space $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetPuzzleAndSolution{
    param(
        [Parameter(Mandatory=$true)]
        [string]$coin_id,
        [Parameter(Mandatory=$true)]
        [int64]$height
    )

    $json = @{
        'coin_id'=$coin_id
        'height'=$height
    } | ConvertTo-Json

    chia rpc full_node get_puzzle_and_solution $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetRecentSignagePointOrEOS{
    param(
        [parameter(Mandatory=$true,ParameterSetName="WithSPHash")]
        [string]$sp_hash,
        [parameter(Mandatory=$true,ParameterSetName="WithChallengeHash")]
        [string]$challenge_hash
    )

    $json = @{} 
    if($sp_hash){
        $json.Add('sp_hash',$sp_hash)
    }
    if($challenge_hash){
        $json.Add('challenge_hash',$challenge_hash)
    }
    $json = $json | ConvertTo-Json

    chia rpc full_node get_recent_signage_point_or_eos $json | ConvertFrom-Json
}

Function Invoke-FullNodeGetRoutes{
  
    chia rpc full_node get_routes | ConvertFrom-Json
}

Function Invoke-FullNodeGetUnfinishedBlockHeaders{

    chia rpc full_node get_unfinished_block_headers | ConvertFrom-Json
}

Function Invoke-healthz{
    chia rpc full_node healthz
}

Function Invoke-PushTx{
    param(
        [Parameter(Mandatory=$true)]
        [string]$spend_bundle
    )

    chia rpc full_node push_tx $spend_bundle | ConvertFrom-Json

}
