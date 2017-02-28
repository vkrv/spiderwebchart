Item {
	property string text;
	height: decsText.height + 12;
	width: 300;

	Text {
		id: decsText;
		x: 64;
		width: 100% - 70;
		wrapMode: Text.WordWrap;
		y: 8;
		font.pixelSize: 16;
		font.weight: 300;
		color: "#444444";
		text: parent.text;
	}
}