all:
	@stack build
	@stack exec lambda-calculus-interpreter-exe

docker:
	@docker build .
