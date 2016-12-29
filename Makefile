all: compile

compile:
	mix compile

install:
	mix deps.get
	mix compile

run:
	iex -S mix

tests: primes_test redis_test funbox_test

primes_test:
	mix test --no-start --seed 0 test/funbox/primes_test.exs

redis_test:
	mix test --no-start --seed 0 test/funbox/redis_test.exs

funbox_test:
	mix test test/funbox_test.exs
