if [ $(getconf LONG_BIT) == "64" ]
then
echo "***** Driver 64 bit*****"
sudo java -Djava.library.path=./gui/jnilib/64 -jar gui/XilinxGUI.jar
else
echo "***** Driver 32 bit*****"
sudo java -Djava.library.path=./gui/jnilib/32 -jar gui/XilinxGUI.jar
fi

