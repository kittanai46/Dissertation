const crypto = require('crypto');

const TOKEN_TTL_SECONDS = Number(process.env.API_TOKEN_TTL_SECONDS || 86400);

function getSecret() {
  const secret = process.env.API_TOKEN_SECRET;
  if (!secret && process.env.NODE_ENV === 'production') {
    throw new Error('API_TOKEN_SECRET must be configured in production');
  }
  return secret || 'development-api-token-secret-change-me';
}

function encode(value) {
  return Buffer.from(value).toString('base64url');
}

function sign(value) {
  return crypto.createHmac('sha256', getSecret()).update(value).digest('base64url');
}

function createApiToken(user) {
  const now = Math.floor(Date.now() / 1000);
  const payload = encode(JSON.stringify({
    sub: user.id_number,
    role: user.role,
    iat: now,
    exp: now + TOKEN_TTL_SECONDS
  }));
  return `${payload}.${sign(payload)}`;
}

function verifyApiToken(token) {
  if (!token || !token.includes('.')) return null;
  const [payload, signature] = token.split('.');
  const expected = sign(payload);
  const suppliedBuffer = Buffer.from(signature);
  const expectedBuffer = Buffer.from(expected);

  if (suppliedBuffer.length !== expectedBuffer.length ||
      !crypto.timingSafeEqual(suppliedBuffer, expectedBuffer)) {
    return null;
  }

  try {
    const claims = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8'));
    if (!claims.sub || !claims.exp || claims.exp <= Math.floor(Date.now() / 1000)) {
      return null;
    }
    return claims;
  } catch (_) {
    return null;
  }
}

function requireApiAuth(req, res, next) {
  if (req.session && req.session.isLoggedIn) return next();

  const authorization = req.get('authorization') || '';
  const [scheme, token] = authorization.split(' ');
  const claims = scheme === 'Bearer' ? verifyApiToken(token) : null;

  if (!claims) {
    return res.status(401).json({ success: false, error: 'Authentication required' });
  }

  req.apiUser = claims;
  next();
}

module.exports = { createApiToken, requireApiAuth, verifyApiToken };
