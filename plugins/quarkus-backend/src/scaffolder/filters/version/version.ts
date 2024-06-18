export function extractVersionFromKey(
    streamKey: string,
): string {
    if (!streamKey) {
        throw new Error(`StreamKey to be processed cannot be empty`);
    }

    let streamKeyArr = streamKey.split(":")
    if (streamKeyArr.length < 2) {
        throw new Error(`The streamKey is not formatted as: io.quarkus.platform:\<version\>`);
    } else {
        return streamKeyArr[1]
    }
}