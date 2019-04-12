
TARGET=application
OBJ_DIR=$(TARGET)/Debug/rust_obj


.PHONY: application
application:
	# nightly-2019-04-12
	cd src/rust && rustup override set nightly
	cd src/rust && cargo build -v
	mkdir -p $(OBJ_DIR)
	cp src/rust/target/thumbv7em-none-eabihf/debug/librustfactbird.a $(OBJ_DIR)/librustfactbird.o
	cp src/rust/target/thumbv7em-none-eabihf/debug/deps/libfreertos_rs*.rlib $(OBJ_DIR)/libfreertos_rs.o

.PHONY: clean
clean:
	cd src/rust && cargo clean
