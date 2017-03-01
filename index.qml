Item {
	anchors.fill: context;

	Grid {
		y: 20;
		horizontalAlignment: Grid.AlignHCenter;
		width: 100%;
		spacing: 20;

		Rectangle {
			width: Math.min(600, 100%);
			height: width * 0.8;
			border.width: 1;
			border.color: "#DDD";

			WebLink {
				id: download;
				x: 4;
				y: 100% + 3;
				Text {
					text: "DOWNLOAD";
					color: "#1976D2";
					font.pixelSize: 14;
				}
			}

			Canvas {
				id: canvas;
				property Color webColor: colorInput.color;
				property Color fillColor: fillInput.color;
				property int levels: scale.value;
				property string caption: captionInput.text;
				width: 100%; height: 100%;

				onCompleted: {
					this._corners = []
				}

				onWebColorChanged: { this.draw() }
				onCaptionChanged: { this.draw() }
				onFillColorChanged: { this.draw() }

				function setNode(idx, node, value) {
					this._corners[idx] = {name: node, value: value}
					this.draw()
				}

				function removeNode(idx) {
					this._corners.splice(idx, 1);
					this.draw()
				}

				function draw() {
					var corners = this._corners
					if (!corners)
						return

					this.clearAll();

					var w2 = this.width / 2, h2 = this.height / 2
					var r = h2 * 0.85
					var rads = (Math.PI * 2) / corners.length
					var levels = this.levels
					var ctx = this.ctx

					if (this.caption) {
						ctx.font = "20px Roboto"
						ctx.fillStyle = "#444444";
						ctx.textAlign = 'left'
						ctx.fillText(this.caption, 10, 30)
						ctx.stroke();
					}

					ctx.font = "12px Arial";
					ctx.fillStyle = "#444444";
					ctx.strokeStyle = this.webColor;
					ctx.lineWidth = 1;
					this.drawMap = []

					function getCoords(line, level) {
						var angle = rads * line + Math.PI * 1.5
						var rr = r - r * (level / levels)
						var xc = Math.cos(angle) * rr + w2
						var yc = Math.sin(angle) * rr + h2
						return { x: xc, y: yc }
					}

					this.drawMap.push({type: "beginPath"})
					
					for (var l = 0; l < levels; ++l) {
						var start = getCoords(0, 0)
						this.drawMap.push({type: "move", x: start.x, y: start.y})

						for (var i = 0; i <= corners.length; ++i) {
							var res = getCoords(i, l)
							this.drawMap.push({type: "line", x: res.x, y: res.y})

 							if (l === 0 && i !== corners.length) {
 								var x = Math.round(res.x), y = Math.round(res.y)
								this.drawMap.push({type: "line", x: w2, y: h2})

								this.drawMap.push({
									type: "text",
									align: x < w2 ? 'right' : (x > w2 ? 'left' : 'center'),
									x: res.x,
									y: y < h2 ? y - 2 : (y > h2 ? y + 20 : y + 5),
									text: corners[i].name
									})
								this.drawMap.push({type: 'move', x: res.x, y: res.y})
 							}
						}
					}

					this.drawMap.push({type: "beginPath"})
					this.drawMap.push({type: "fillStyle", color: this.fillColor})
					this.drawMap.push({type: "strokeStyle", color: this.fillColor})
					this.drawMap.push({type: "lineWidth", value: 2})

					for (var i = 0; i < corners.length; ++i ){
						var res = getCoords(i, levels - corners[i].value)
						this.drawMap.push({type: 'line', x: res.x, y: res.y})
					}
					this.drawMap.push({type: 'fill'})

					var self = this

					function drawOne() {
						var e = self.drawMap.shift()
						if (!e) {
							self.download.element.dom.download = (self.caption ? self.caption : "awesome_chart") + ".png";
							self.download.href = self.element.dom.toDataURL("image/png");
							return
						}

						switch(e.type) {
							case 'move':
								ctx.moveTo(e.x, e.y)
								break;
							case 'line':
								ctx.lineTo(e.x, e.y)
								break;
							case 'text':
								ctx.textAlign = e.align
								ctx.fillText(e.text, e.x, e.y)
								break;
							case 'beginPath':
								ctx.beginPath();
								break;							
							case 'fill':
								ctx.fill();
								break;
							case 'fillStyle':
								ctx.fillStyle = e.color;
								break;
							case 'strokeStyle':
								ctx.strokeStyle = e.color;
								break;
							case 'lineWidth':
								ctx.lineWidth = e.value;
								break;
						}

						ctx.stroke();
						requestAnimationFrame(drawOne)
					}

					drawOne()
				}
			}
		}

		Column {
			width: 300;
			spacing: 10;

			Row {
				height: 32;
				spacing: 8;

				Text {
					anchors.verticalCenter: parent.verticalCenter;
					font.pixelSize: 16;
					font.weight: 300;
					color: "#444444";
					text: "Chart caption";
				}

				TextInput {
					id: captionInput;
					height: 100%;
					paddings.left: 5;
					placeholder.text: "My Chart";
				}
			}

			Rectangle { width: 233; color: "#DDD"; height: 1; }

			InputWrapper { 
				text: "Web color";
				ColorInput {
					id: colorInput;
					width: 50;
					color: "#f0f7fa";
				}
			}

			InputWrapper {
				text: "Fill color";
				ColorInput {
					id: fillInput;
					width: 50;
					color: "#40C4FF";
				}
			}

			InputWrapper {
				text: "Possible values";

				NumberInput {
					id: scale;
					height: 32;
					value: 5;
					min: 1;
					max: 20;
					Border { width: 1; color: "#BBB"; }

					onValueChanged: {
						canvas.draw(list.count, value)
					}
				}
			}

			Rectangle { width: 233; color: "#DDD"; height: 1; }

			ListView {
				id: list;
				height: contentHeight;
				width: 100%;
				spacing: 8;
				model: ListModel {
					ListElement { name: "Node 1"; value: 0; }
					ListElement { name: "Node 2"; value: 0; }
					ListElement { name: "Node 3"; value: 0; }
				}

				delegate: Item {
					height: 32;
					width: 100%;
					property string text: nameInput.text;
					property int idx: model.index;
					property int value: numInput.value;

					onCompleted: {
						canvas.setNode(this.idx, this.text, this.value)
					}

					NumberInput {
						id: numInput;
						value: model.value;
						height: 100%;
						max: scale.value;
						min: 0;
						Border { width: 1; color: "#BBB"; }
						onValueChanged: {
							canvas.setNode(this.parent.idx, this.parent.text, value)
						}
					}

					TextInput {
						id: nameInput;
						paddings.left: 5;
						x: 60;
						height: 100%;
						text: model.name;
						Border { width: 1; color: "#BBB"; }

						onTextChanged: {
							canvas.setNode(this.parent.idx, this.text, this.parent.value)
						}
					}

					Text {
						x: 240;
						anchors.verticalCenter: parent.verticalCenter;
						text: "REMOVE";
						font.pixelSize: 12;
						color: "#EF5350";
						font.underline: hover.value;
						visible: parent.parent.count > 3;
						property HoverMixin hover: HoverMixin { cursor: "pointer"; }
						onClicked: {
							canvas.removeNode(this.parent.idx)
							this.parent.parent.model.remove(this.parent.idx)
						}
					}
				}
			}

			WebItem {
				width: 120;
				x: 68;
				height: 44;
				radius: 12;
				color: !hover ? "#F6F6EE" : "#EEEEDD";
				TextMixin { text: "ADD"; color: "#558B2F"; }
				Behavior on color { Animation {}}
				property int corners: 3;
				onClicked: { list.model.append({name: "Node " + (list.model.count + 1), value: 0}) }
			}
		}
	}
}