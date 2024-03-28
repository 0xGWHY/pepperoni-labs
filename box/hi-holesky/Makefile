include .env
export

deploy-entrypoint:
	@forge fmt .; \
	forge script script/EntryPointScript.s.sol:EntryPointScript --use solc:0.8.12 --chain holesky --rpc-url $$RPC_URL_HOLESKY --verifier etherscan --etherscan-api-key $$ETHERSCAN_API_KEY --broadcast --names --verify -vvvv; \

deploy-02:
	@read -p "Have you reviewed the Constants.sol contract? (Y/N): " input_review; \
	input_review=`echo $$input_review | tr '[:upper:]' '[:lower:]'`; \
	if [ "$$input_review" = "y" ]; then \
		forge fmt .; \
		read -p "Network? (mainnet/HOLESKY): " input_network; \
		if [ "$$input_network" = "mainnet" ]; then \
			forge script script/02_DeployCore.s.sol:DeployCore --rpc-url $$RPC_URL_MAINNET --etherscan-api-key $$ETHERSCAN_API_KEY --broadcast --verify -vvvvv; \
		elif [ "$$input_network" = "HOLESKY" ]; then \
			forge script script/02_DeployCore.s.sol:DeployCore --rpc-url $$RPC_URL_HOLESKY --etherscan-api-key $$ETHERSCAN_API_KEY --broadcast --names --verify -vvvvv; \
		else \
			echo "Invalid network. Please enter either 'mainnet' or 'HOLESKY'."; \
		fi; \
	else \
		echo "Please review the Constants.sol contract and redeploy."; \
	fi

deploy-HOLESKY:
	@read -p "Contract (e.g. src/Contract.sol:Contract): " input_path; \
	forge fmt .; \
	forge create $$input_path --rpc-url $$RPC_URL_HOLESKY --private-key $$DYLAN_KEY --etherscan-api-key $$ETHERSCAN_API_KEY --verify ;

verify-holesky:
	@read -p "Contract Address: " input_address; \
	read -p "Contract path & name (path:name): " input_contract; \
	forge verify-contract --watch --chain holesky \
	--etherscan-api-key JZYVICTA5WADJX5SMDYRG6BZ5VID1U265H \
	$$input_address $$input_contract; \