// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./SepoliaUniV2Addresses.sol";

contract UniV2Helper is SepoliaUniV2Addresses {
    IUniswapV2Router02 public constant router =
        IUniswapV2Router02(UNI_V2_ROUTER_ADDR);

    IUniswapV2Factory public constant factory =
        IUniswapV2Factory(UNI_V2_FACTORY_ADDR);

}