include .env
export

deploy:
	@echo "Deploying..."
	@forge script script/Deploy.s.sol:DeployScript --rpc-url $$RPC_URL --etherscan-api-key $$ETHERSCAN_KEY --broadcast --verify -vvvv

deploy-testnet:
	@echo "Deploying..."
	@forge script script/Deploy.s.sol:DeployScript --rpc-url $$SEPOLIA_HTTP --etherscan-api-key $$ETHERSCAN_KEY --broadcast --verify -vvvv

verify:
	@read -p "Contract Address: " input_address; \
	read -p "Contract path & name (path:name): " input_contract; \
	read -p "Chain name: " input_chain; \
	forge verify-contract $$input_address $$input_contract --chain $$input_chain --etherscan-api-key $$ETHERSCAN_KEY --watch