function findOsc8St(text, fromIndex) {
	const escIndex = text.indexOf("\u001b\\", fromIndex);
	const belIndex = text.indexOf("\u0007", fromIndex);

	if (escIndex === -1 && belIndex === -1) {
		return { index: -1, length: 0 };
	}
	if (escIndex === -1) {
		return { index: belIndex, length: 1 };
	}
	if (belIndex === -1) {
		return { index: escIndex, length: 2 };
	}
	return escIndex < belIndex
		? { index: escIndex, length: 2 }
		: { index: belIndex, length: 1 };
}

function pushSegment(segments, text, url) {
	if (text.length === 0) {
		return;
	}

	segments.push({ text, url });
}

function parseOsc8Segments(text) {
	const segments = [];
	let index = 0;

	while (index < text.length) {
		const start = text.indexOf("\u001b]8;", index);
		if (start === -1) {
			pushSegment(segments, text.slice(index), null);
			break;
		}

		pushSegment(segments, text.slice(index, start), null);

		const paramsEnd = text.indexOf(";", start + 4);
		if (paramsEnd === -1) {
			pushSegment(segments, text.slice(start), null);
			break;
		}

		const startSt = findOsc8St(text, paramsEnd + 1);
		if (startSt.index === -1) {
			pushSegment(segments, text.slice(start), null);
			break;
		}

		const url = text.slice(paramsEnd + 1, startSt.index);
		const textStart = startSt.index + startSt.length;

		const closeStart = text.indexOf("\u001b]8;;", textStart);
		if (closeStart === -1) {
			pushSegment(segments, text.slice(start), null);
			break;
		}

		const endSt = findOsc8St(text, closeStart + 5);
		if (endSt.index === -1) {
			pushSegment(segments, text.slice(start), null);
			break;
		}

		pushSegment(segments, text.slice(textStart, closeStart), url);

		index = endSt.index + endSt.length;
	}

	return segments;
}

module.exports = {
	parseOsc8Segments,
};
