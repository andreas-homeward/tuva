{{ config(
     enabled = var('claims_enabled', False) | as_bool
   )
}}

with base as (
select
    person_id
    , payer
    , data_source
    , recorded_date
    , model_version
    , claim_id
    , hcc_code
    , hcc_description
    , suspect_hcc_flag
    , eligible_claim_flag
    , hcc_type
    , hcc_source
    -- Ensure only 1 hcc type per HCC
    , rank() over (
        partition by person_id, payer, data_source, claim_id, hcc_code, model_version 
            order by case 
                        when hcc_type = 'captured' then 1
                        when hcc_type = 'suspect' then 2
                     end
    ) as hcc_type_rank
from {{ ref('hcc_recapture__int_suspect_hccs')}}
)

select 
    * 
from base
where hcc_type_rank = 1

