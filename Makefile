
GameDeployTest.app: GameDeployTest.love Info.plist
	cp -r /Applications/love.app ./GameDeployTest.app
	cp ./GameDeployTest.love ./GameDeployTest.app/Contents/Resources/
	cp ./Info.plist ./GameDeployTest.app/Contents/
	zip -ry GameDeployTest_osx.zip GameDeployTest.app 

GameDeployTest.love: clean main.lua
	zip GameDeployTest.love ./*

clean:
	rm -rf ./*.love
	rm -rf ./*.app
	rm -rf ./*.zip
