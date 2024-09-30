install:
	pixi install
	pixi r pre-commit install

test:
	pixi r test

python:
	pixi r python