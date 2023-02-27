pragma solidity ^0.8.13;

interface IAaveLendingPool {
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

interface ICurvePool {
    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount)
        external;

    function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount)
        external;

    function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount)
        external;

    function remove_liquidity_imbalance(
        uint256[3] memory amounts,
        uint256 max_burn_amount
    ) external;

    function remove_liquidity_one_coin(
        uint256 token_amount,
        int128 i,
        uint256 min_amount
    ) external;
}
