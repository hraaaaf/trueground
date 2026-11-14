import {makeHandler} from './minimal-mcp.mjs';
import fixture from './fixture.mjs';
// NOT DEPLOYED: independent proof-of-concept, no D1/Windows access.
// Staging environment requires AUTH0_ISSUER, AUTH0_AUDIENCE, AUTH0_ALLOWED_SUB.
export default {fetch:makeHandler({fixture})};
