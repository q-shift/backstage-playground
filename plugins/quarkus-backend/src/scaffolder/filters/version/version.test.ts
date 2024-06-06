import { SecureTemplater } from './SecureTemplater';
import {extractVersionFromKey} from "./version";

describe('QuarkusStreamKey', () => {
    it('should get an error as streamKey is not well formatted => io.quarkus.platform_3.9 ', async () => {
        const renderWith = await SecureTemplater.loadRenderer({
            templateFilters: {
                extractVersionFromKey: (streamKey) => extractVersionFromKey(streamKey as string),
            },
        });

        let ctx = {inputValue: 'io.quarkus.platform_3.9'};
        expect(() => renderWith('${{  inputValue | extractVersionFromKey }}', ctx),).toThrow(
            /Error: The streamKey is not formatted as: io.quarkus.platform:<version>/,
        );
    });

    it('should not get an error as streamKey is well formatted => io.quarkus.platform:3.9 ', async () => {
        const renderWith = await SecureTemplater.loadRenderer({
            templateFilters: {
                extractVersionFromKey: (streamKey) => extractVersionFromKey(streamKey as string),
            },
        });

        let ctx = {inputValue: 'io.quarkus.platform:3.10'};
        expect(renderWith('${{  inputValue | extractVersionFromKey }}', ctx)).toBe('3.10');
    });
});
