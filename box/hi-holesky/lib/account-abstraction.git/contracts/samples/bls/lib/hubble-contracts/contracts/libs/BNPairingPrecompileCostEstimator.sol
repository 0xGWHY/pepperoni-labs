// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

contract BNPairingPrecompileCostEstimator {
    uint256 public baseCost;
    uint256 public perPairCost;

    // G1 Generator
    uint256 private constant G1_X = 1;
    uint256 private constant G1_Y = 2;

    // G2 genarator
    // prettier-ignore
    uint256 private constant G2_X0 =
        10_857_046_999_023_057_135_944_570_762_232_829_481_370_756_359_578_518_086_990_519_993_285_655_852_781;
    // prettier-ignore
    uint256 private constant G2_X1 =
        11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634;
    // prettier-ignore
    uint256 private constant G2_Y0 =
        8_495_653_923_123_431_417_604_973_247_489_272_438_418_190_587_263_600_148_770_280_649_306_958_101_930;
    // prettier-ignore
    uint256 private constant G2_Y1 =
        4_082_367_875_863_433_681_332_203_403_145_435_568_316_851_327_593_401_208_105_741_076_214_120_093_531;

    // G2 negated genarator y coordinates
    // prettier-ignore
    uint256 private constant N_G2_Y0 =
        13_392_588_948_715_843_804_641_432_497_768_002_650_278_120_570_034_223_513_918_757_245_338_268_106_653;
    // prettier-ignore
    uint256 private constant N_G2_Y1 =
        17_805_874_995_975_841_540_914_202_342_111_839_520_379_459_829_704_422_454_583_296_818_431_106_115_052;

    function run() external {
        _run();
    }

    function getGasCost(uint256 pairCount) external view returns (uint256) {
        return pairCount * perPairCost + baseCost;
    }

    function _run() internal {
        uint256 gasCost1Pair = _gasCost1Pair();
        uint256 gasCost2Pair = _gasCost2Pair();
        perPairCost = gasCost2Pair - gasCost1Pair;
        baseCost = gasCost1Pair - perPairCost;
    }

    function _gasCost1Pair() internal view returns (uint256) {
        uint256[6] memory input = [G1_X, G1_Y, G2_X1, G2_X0, G2_Y1, G2_Y0];
        uint256[1] memory out;
        bool callSuccess;
        uint256 suppliedGas = gasleft() - 2000;
        require(gasleft() > 2000, "BNPairingPrecompileCostEstimator: not enough gas, single pair");
        uint256 gasT0 = gasleft();
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            callSuccess := staticcall(suppliedGas, 8, input, 192, out, 0x20)
        }
        uint256 gasCost = gasT0 - gasleft();
        require(callSuccess, "BNPairingPrecompileCostEstimator: single pair call is failed");
        require(out[0] == 0, "BNPairingPrecompileCostEstimator: single pair call result must be 0");
        return gasCost;
    }

    function _gasCost2Pair() internal view returns (uint256) {
        uint256[12] memory input = [G1_X, G1_Y, G2_X1, G2_X0, G2_Y1, G2_Y0, G1_X, G1_Y, G2_X1, G2_X0, N_G2_Y1, N_G2_Y0];
        uint256[1] memory out;
        bool callSuccess;
        uint256 suppliedGas = gasleft() - 2000;
        require(gasleft() > 2000, "BNPairingPrecompileCostEstimator: not enough gas, couple pair");
        uint256 gasT0 = gasleft();
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            callSuccess := staticcall(suppliedGas, 8, input, 384, out, 0x20)
        }
        uint256 gasCost = gasT0 - gasleft();
        require(callSuccess, "BNPairingPrecompileCostEstimator: couple pair call is failed");
        require(out[0] == 1, "BNPairingPrecompileCostEstimator: couple pair call result must be 1");
        return gasCost;
    }
}
