# Operational Excellence

Operational excellence in React application deployment encompasses comprehensive strategies for maintaining high availability, implementing robust disaster recovery procedures, and establishing security frameworks that support sustainable long-term operations. Professional operations extend beyond initial deployment—they require systematic approaches to capacity planning, incident response, and continuous improvement processes.

Modern operational excellence integrates automated scaling strategies, proactive monitoring systems, and comprehensive backup procedures that ensure application resilience under varying load conditions and unexpected failures. Effective operational frameworks enable teams to maintain service quality while supporting rapid feature development and deployment cycles.

This section provides comprehensive guidance for establishing and maintaining operational excellence in React application deployment, covering security best practices, disaster recovery planning, and performance optimization strategies that support scalable, reliable production operations.

::: important
**Operational Excellence Philosophy**

Build operational systems that prioritize reliability, security, and maintainability over short-term convenience. Every operational decision should consider long-term sustainability, risk mitigation, and team scalability. The goal is creating self-healing, observable systems that enable confident operations while minimizing manual intervention and operational overhead.
:::

## Security Best Practices

Implement comprehensive security frameworks that protect React applications, user data, and infrastructure from evolving threats.

### Content Security Policy (CSP) Implementation

Establish robust CSP configurations that prevent XSS attacks and unauthorized resource loading:

::: example
**Advanced CSP Configuration**

```javascript
// security/csp.js
const CSP_POLICIES = {
  development: {
    'default-src': ["'self'"],
    'script-src': [
      "'self'",
      "'unsafe-inline'", // Required for development
      "'unsafe-eval'", // Required for development tools
      'localhost:*',
      '*.webpack.dev'
    ],
    'style-src': [
      "'self'",
      "'unsafe-inline'", // Required for styled-components
      'fonts.googleapis.com'
    ],
    'font-src': [
      "'self'",
      'fonts.gstatic.com',
      'data:'
    ],
    'img-src': [
      "'self'",
      'data:',
      'blob:',
      '*.amazonaws.com'
    ],
    'connect-src': [
      "'self'",
      'localhost:*',
      'ws://localhost:*',
      '*.api.yourapp.com'
    ]
  },
  
  production: {
    'default-src': ["'self'"],
    'script-src': [
      "'self'",
      "'sha256-randomhash123'", // Hash of inline scripts
      '*.vercel.app'
    ],
    'style-src': [
      "'self'",
      "'unsafe-inline'", // Consider using nonces instead
      'fonts.googleapis.com'
    ],
    'font-src': [
      "'self'",
      'fonts.gstatic.com'
    ],
    'img-src': [
      "'self'",
      'data:',
      '*.amazonaws.com',
      '*.cloudinary.com'
    ],
    'connect-src': [
      "'self'",
      'api.yourapp.com',
      '*.sentry.io',
      '*.analytics.google.com'
    ],
    'frame-ancestors': ["'none'"],
    'base-uri': ["'self'"],
    'object-src': ["'none'"],
    'upgrade-insecure-requests': []
  }
}

export function generateCSPHeader(environment = 'production') {
  const policies = CSP_POLICIES[environment]
  
  const cspString = Object.entries(policies)
    .map(([directive, sources]) => {
      if (sources.length === 0) {
        return directive
      }
      return `${directive} ${sources.join(' ')}`
    })
    .join('; ')
  
  return cspString
}

// Express.js middleware for CSP
export function cspMiddleware(req, res, next) {
  const environment = process.env.NODE_ENV
  const csp = generateCSPHeader(environment)
  
  res.setHeader('Content-Security-Policy', csp)
  res.setHeader('X-Content-Type-Options', 'nosniff')
  res.setHeader('X-Frame-Options', 'DENY')
  res.setHeader('X-XSS-Protection', '1; mode=block')
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()')
  
  next()
}

// Webpack plugin for CSP nonce generation
export class CSPNoncePlugin {
  apply(compiler) {
    compiler.hooks.compilation.tap('CSPNoncePlugin', (compilation) => {
      compilation.hooks.htmlWebpackPluginBeforeHtmlProcessing.tap(
        'CSPNoncePlugin',
        (data) => {
          const nonce = this.generateNonce()
          
          // Add nonce to script tags
          data.html = data.html.replace(
            /<script/g,
            `<script nonce="${nonce}"`
          )
          
          // Add nonce to style tags
          data.html = data.html.replace(
            /<style/g,
            `<style nonce="${nonce}"`
          )
          
          return data
        }
      )
    })
  }
  
  generateNonce() {
    return require('crypto').randomBytes(16).toString('base64')
  }
}
```
:::

### Environment Security Configuration

Implement secure environment variable management and secret handling:

::: example
**Secure Environment Management**

```javascript
// security/environment.js
class EnvironmentManager {
  constructor() {
    this.requiredEnvVars = new Set()
    this.sensitivePatterns = [
      /password/i,
      /secret/i,
      /key/i,
      /token/i,
      /private/i
    ]
  }

  validateEnvironment() {
    const missing = []
    const invalid = []

    // Check required environment variables
    this.requiredEnvVars.forEach(varName => {
      if (!process.env[varName]) {
        missing.push(varName)
      }
    })

    // Validate sensitive variables are not exposed to client
    Object.keys(process.env).forEach(key => {
      if (this.isSensitive(key) && key.startsWith('REACT_APP_')) {
        invalid.push(key)
      }
    })

    if (missing.length > 0) {
      throw new Error(`Missing required environment variables: ${missing.join(', ')}`)
    }

    if (invalid.length > 0) {
      throw new Error(`Sensitive variables exposed to client: ${invalid.join(', ')}`)
    }
  }

  isSensitive(varName) {
    return this.sensitivePatterns.some(pattern => pattern.test(varName))
  }

  requireEnvVar(varName) {
    this.requiredEnvVars.add(varName)
    return this
  }

  getClientConfig() {
    // Return only client-safe environment variables
    const clientConfig = {}
    
    Object.keys(process.env).forEach(key => {
      if (key.startsWith('REACT_APP_') && !this.isSensitive(key)) {
        clientConfig[key] = process.env[key]
      }
    })

    return clientConfig
  }

  getServerConfig() {
    // Return server-only configuration
    const serverConfig = {}
    
    Object.keys(process.env).forEach(key => {
      if (!key.startsWith('REACT_APP_')) {
        serverConfig[key] = process.env[key]
      }
    })

    return serverConfig
  }

  maskSensitiveValues(obj) {
    const masked = { ...obj }
    
    Object.keys(masked).forEach(key => {
      if (this.isSensitive(key)) {
        const value = masked[key]
        if (typeof value === 'string' && value.length > 0) {
          masked[key] = value.substring(0, 4) + '*'.repeat(Math.max(0, value.length - 4))
        }
      }
    })

    return masked
  }
}

export const envManager = new EnvironmentManager()

// Environment validation for different stages
export function validateProductionEnvironment() {
  envManager
    .requireEnvVar('REACT_APP_API_URL')
    .requireEnvVar('REACT_APP_SENTRY_DSN')
    .requireEnvVar('DATABASE_URL')
    .requireEnvVar('JWT_SECRET')
    .requireEnvVar('REDIS_URL')
    .validateEnvironment()
}

export function validateStagingEnvironment() {
  envManager
    .requireEnvVar('REACT_APP_API_URL')
    .requireEnvVar('DATABASE_URL')
    .validateEnvironment()
}

// Secure secret management
export class SecretManager {
  constructor() {
    this.secrets = new Map()
    this.encrypted = new Map()
  }

  async loadSecrets() {
    try {
      // Load from secure storage (AWS Secrets Manager, Azure Key Vault, etc.)
      const secrets = await this.fetchFromSecureStorage()
      
      secrets.forEach(({ key, value }) => {
        this.secrets.set(key, value)
      })
      
      console.log(`Loaded ${secrets.length} secrets`)
    } catch (error) {
      console.error('Failed to load secrets:', error)
      throw error
    }
  }

  async fetchFromSecureStorage() {
    // Example: AWS Secrets Manager integration
    if (process.env.AWS_SECRET_NAME) {
      const AWS = require('aws-sdk')
      const secretsManager = new AWS.SecretsManager()
      
      const response = await secretsManager.getSecretValue({
        SecretId: process.env.AWS_SECRET_NAME
      }).promise()
      
      const secrets = JSON.parse(response.SecretString)
      return Object.entries(secrets).map(([key, value]) => ({ key, value }))
    }

    // Fallback to environment variables
    return Object.entries(process.env)
      .filter(([key]) => !key.startsWith('REACT_APP_'))
      .map(([key, value]) => ({ key, value }))
  }

  getSecret(key) {
    if (!this.secrets.has(key)) {
      throw new Error(`Secret '${key}' not found`)
    }
    return this.secrets.get(key)
  }

  hasSecret(key) {
    return this.secrets.has(key)
  }

  rotateSecret(key, newValue) {
    // Implement secret rotation logic
    this.secrets.set(key, newValue)
    
    // Optionally persist to secure storage
    this.persistSecret(key, newValue)
  }

  async persistSecret(key, value) {
    // Persist to secure storage
    try {
      // Implementation depends on storage backend
      console.log(`Secret '${key}' rotated successfully`)
    } catch (error) {
      console.error(`Failed to rotate secret '${key}':`, error)
      throw error
    }
  }
}

export const secretManager = new SecretManager()
```
:::

### API Security Implementation

Secure API communications and implement proper authentication/authorization:

::: example
**Comprehensive API Security**

```javascript
// security/apiSecurity.js
import rateLimit from 'express-rate-limit'
import helmet from 'helmet'
import cors from 'cors'
import jwt from 'jsonwebtoken'

// Rate limiting configuration
export const createRateLimiter = (options = {}) => {
  const defaultOptions = {
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: {
      error: 'Too many requests from this IP, please try again later.',
      retryAfter: 15 * 60 // seconds
    },
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req, res) => {
      res.status(429).json({
        error: 'Rate limit exceeded',
        retryAfter: Math.round(options.windowMs / 1000)
      })
    }
  }

  return rateLimit({ ...defaultOptions, ...options })
}

// API-specific rate limiters
export const authRateLimit = createRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 login attempts per 15 minutes
  skipSuccessfulRequests: true
})

export const apiRateLimit = createRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 1000 // 1000 API calls per 15 minutes
})

// Security middleware setup
export function setupSecurityMiddleware(app) {
  // Helmet for security headers
  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'"],
        styleSrc: ["'self'", "'unsafe-inline'", 'fonts.googleapis.com'],
        fontSrc: ["'self'", 'fonts.gstatic.com'],
        imgSrc: ["'self'", 'data:', '*.amazonaws.com']
      }
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    }
  }))

  // CORS configuration
  app.use(cors({
    origin: function (origin, callback) {
      const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || []
      
      // Allow requests with no origin (mobile apps, Postman, etc.)
      if (!origin) return callback(null, true)
      
      if (allowedOrigins.includes(origin)) {
        callback(null, true)
      } else {
        callback(new Error('Not allowed by CORS'))
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
  }))

  // Rate limiting
  app.use('/api/auth', authRateLimit)
  app.use('/api', apiRateLimit)
}

// JWT token management
export class TokenManager {
  constructor() {
    this.accessTokenSecret = process.env.JWT_ACCESS_SECRET
    this.refreshTokenSecret = process.env.JWT_REFRESH_SECRET
    this.accessTokenExpiry = '15m'
    this.refreshTokenExpiry = '7d'
  }

  generateAccessToken(payload) {
    return jwt.sign(payload, this.accessTokenSecret, {
      expiresIn: this.accessTokenExpiry,
      issuer: 'yourapp.com',
      audience: 'yourapp-users'
    })
  }

  generateRefreshToken(payload) {
    return jwt.sign(payload, this.refreshTokenSecret, {
      expiresIn: this.refreshTokenExpiry,
      issuer: 'yourapp.com',
      audience: 'yourapp-users'
    })
  }

  verifyAccessToken(token) {
    try {
      return jwt.verify(token, this.accessTokenSecret)
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('Access token expired')
      }
      throw new Error('Invalid access token')
    }
  }

  verifyRefreshToken(token) {
    try {
      return jwt.verify(token, this.refreshTokenSecret)
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('Refresh token expired')
      }
      throw new Error('Invalid refresh token')
    }
  }

  generateTokenPair(payload) {
    return {
      accessToken: this.generateAccessToken(payload),
      refreshToken: this.generateRefreshToken(payload)
    }
  }
}

// Authentication middleware
export function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1] // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' })
  }

  try {
    const tokenManager = new TokenManager()
    const decoded = tokenManager.verifyAccessToken(token)
    req.user = decoded
    next()
  } catch (error) {
    return res.status(403).json({ error: error.message })
  }
}

// Authorization middleware
export function authorize(permissions = []) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' })
    }

    const userPermissions = req.user.permissions || []
    const hasPermission = permissions.every(permission => 
      userPermissions.includes(permission)
    )

    if (!hasPermission) {
      return res.status(403).json({ 
        error: 'Insufficient permissions',
        required: permissions,
        current: userPermissions
      })
    }

    next()
  }
}

// Input validation and sanitization
export function validateInput(schema) {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    })

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }))
      
      return res.status(400).json({
        error: 'Validation failed',
        details: errors
      })
    }

    req.body = value
    next()
  }
}

// API endpoint protection
export function protectEndpoint(options = {}) {
  const {
    requireAuth = true,
    permissions = [],
    rateLimit = apiRateLimit,
    validation = null
  } = options

  return [
    rateLimit,
    ...(requireAuth ? [authenticateToken] : []),
    ...(permissions.length > 0 ? [authorize(permissions)] : []),
    ...(validation ? [validateInput(validation)] : [])
  ]
}
```
:::

## Disaster Recovery and Backup Strategies

Implement comprehensive backup and recovery procedures that ensure rapid restoration of service in case of failures.

### Automated Backup Systems

Establish automated backup procedures for application data and configurations:

::: example
**Comprehensive Backup Strategy**

```javascript
// backup/backupManager.js
import AWS from 'aws-sdk'
import cron from 'node-cron'

class BackupManager {
  constructor() {
    this.s3 = new AWS.S3()
    this.rds = new AWS.RDS()
    this.backupBucket = process.env.BACKUP_S3_BUCKET
    this.retentionPolicies = {
      daily: 30,    // Keep daily backups for 30 days
      weekly: 12,   // Keep weekly backups for 12 weeks
      monthly: 12   // Keep monthly backups for 12 months
    }
  }

  initializeBackupSchedules() {
    // Daily database backup at 2 AM UTC
    cron.schedule('0 2 * * *', () => {
      this.performDatabaseBackup('daily')
    })

    // Weekly full backup on Sundays at 1 AM UTC
    cron.schedule('0 1 * * 0', () => {
      this.performFullBackup('weekly')
    })

    // Monthly backup on the 1st at midnight UTC
    cron.schedule('0 0 1 * *', () => {
      this.performFullBackup('monthly')
    })

    console.log('Backup schedules initialized')
  }

  async performDatabaseBackup(frequency) {
    try {
      console.log(`Starting ${frequency} database backup...`)

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
      const backupId = `db-backup-${frequency}-${timestamp}`

      // Create RDS snapshot
      await this.rds.createDBSnapshot({
        DBInstanceIdentifier: process.env.RDS_INSTANCE_ID,
        DBSnapshotIdentifier: backupId
      }).promise()

      // Export additional database metadata
      await this.backupDatabaseMetadata(backupId)

      // Clean up old backups
      await this.cleanupOldBackups('database', frequency)

      console.log(`Database backup completed: ${backupId}`)
      
      // Send notification
      await this.sendBackupNotification('database', 'success', backupId)

    } catch (error) {
      console.error('Database backup failed:', error)
      await this.sendBackupNotification('database', 'failure', null, error)
      throw error
    }
  }

  async performFullBackup(frequency) {
    try {
      console.log(`Starting ${frequency} full backup...`)

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
      const backupId = `full-backup-${frequency}-${timestamp}`

      // Database backup
      await this.performDatabaseBackup(frequency)

      // Application files backup
      await this.backupApplicationFiles(backupId)

      // Configuration backup
      await this.backupConfigurations(backupId)

      // User uploads backup
      await this.backupUserUploads(backupId)

      // Logs backup
      await this.backupLogs(backupId)

      // Create backup manifest
      await this.createBackupManifest(backupId)

      console.log(`Full backup completed: ${backupId}`)
      
      await this.sendBackupNotification('full', 'success', backupId)

    } catch (error) {
      console.error('Full backup failed:', error)
      await this.sendBackupNotification('full', 'failure', null, error)
      throw error
    }
  }

  async backupApplicationFiles(backupId) {
    const sourceDir = process.env.APP_SOURCE_DIR || '/app'
    const backupKey = `${backupId}/application-files.tar.gz`

    // Create compressed archive
    const archive = await this.createTarArchive(sourceDir, [
      'node_modules',
      '.git',
      'logs',
      'tmp'
    ])

    // Upload to S3
    await this.s3.upload({
      Bucket: this.backupBucket,
      Key: backupKey,
      Body: archive,
      StorageClass: 'STANDARD_IA'
    }).promise()

    console.log(`Application files backed up: ${backupKey}`)
  }

  async backupConfigurations(backupId) {
    const configurations = {
      environment: process.env,
      packageJson: require('../../package.json'),
      dockerConfig: await this.readFile('/app/Dockerfile'),
      nginxConfig: await this.readFile('/etc/nginx/nginx.conf'),
      backupTimestamp: new Date().toISOString()
    }

    const backupKey = `${backupId}/configurations.json`

    await this.s3.upload({
      Bucket: this.backupBucket,
      Key: backupKey,
      Body: JSON.stringify(configurations, null, 2),
      ContentType: 'application/json'
    }).promise()

    console.log(`Configurations backed up: ${backupKey}`)
  }

  async backupUserUploads(backupId) {
    const uploadsDir = process.env.UPLOADS_DIR || '/app/uploads'
    const backupKey = `${backupId}/user-uploads.tar.gz`

    if (await this.directoryExists(uploadsDir)) {
      const archive = await this.createTarArchive(uploadsDir)

      await this.s3.upload({
        Bucket: this.backupBucket,
        Key: backupKey,
        Body: archive,
        StorageClass: 'STANDARD_IA'
      }).promise()

      console.log(`User uploads backed up: ${backupKey}`)
    }
  }

  async backupLogs(backupId) {
    const logsDir = process.env.LOGS_DIR || '/app/logs'
    const backupKey = `${backupId}/logs.tar.gz`

    if (await this.directoryExists(logsDir)) {
      const archive = await this.createTarArchive(logsDir)

      await this.s3.upload({
        Bucket: this.backupBucket,
        Key: backupKey,
        Body: archive,
        StorageClass: 'GLACIER'
      }).promise()

      console.log(`Logs backed up: ${backupKey}`)
    }
  }

  async createBackupManifest(backupId) {
    const manifest = {
      backupId,
      timestamp: new Date().toISOString(),
      components: {
        database: `${backupId}/database-snapshot`,
        applicationFiles: `${backupId}/application-files.tar.gz`,
        configurations: `${backupId}/configurations.json`,
        userUploads: `${backupId}/user-uploads.tar.gz`,
        logs: `${backupId}/logs.tar.gz`
      },
      metadata: {
        version: process.env.APP_VERSION,
        environment: process.env.NODE_ENV,
        region: process.env.AWS_REGION
      }
    }

    await this.s3.upload({
      Bucket: this.backupBucket,
      Key: `${backupId}/manifest.json`,
      Body: JSON.stringify(manifest, null, 2),
      ContentType: 'application/json'
    }).promise()

    console.log(`Backup manifest created: ${backupId}/manifest.json`)
    return manifest
  }

  async cleanupOldBackups(type, frequency) {
    const retentionDays = this.retentionPolicies[frequency]
    const cutoffDate = new Date()
    cutoffDate.setDate(cutoffDate.getDate() - retentionDays)

    try {
      // List backups
      const backups = await this.listBackups(type, frequency)
      const oldBackups = backups.filter(backup => 
        new Date(backup.timestamp) < cutoffDate
      )

      // Delete old backups
      for (const backup of oldBackups) {
        await this.deleteBackup(backup.id)
        console.log(`Deleted old backup: ${backup.id}`)
      }

      console.log(`Cleaned up ${oldBackups.length} old ${frequency} backups`)

    } catch (error) {
      console.error('Backup cleanup failed:', error)
    }
  }

  async restoreFromBackup(backupId, components = ['database', 'configurations']) {
    try {
      console.log(`Starting restore from backup: ${backupId}`)

      // Get backup manifest
      const manifest = await this.getBackupManifest(backupId)

      // Restore each requested component
      for (const component of components) {
        await this.restoreComponent(component, manifest.components[component])
      }

      console.log(`Restore completed from backup: ${backupId}`)
      
      await this.sendRestoreNotification('success', backupId, components)

    } catch (error) {
      console.error('Restore failed:', error)
      await this.sendRestoreNotification('failure', backupId, components, error)
      throw error
    }
  }

  async restoreComponent(component, componentPath) {
    switch (component) {
      case 'database':
        await this.restoreDatabase(componentPath)
        break
      case 'configurations':
        await this.restoreConfigurations(componentPath)
        break
      case 'userUploads':
        await this.restoreUserUploads(componentPath)
        break
      default:
        console.warn(`Unknown component: ${component}`)
    }
  }

  async getBackupManifest(backupId) {
    const response = await this.s3.getObject({
      Bucket: this.backupBucket,
      Key: `${backupId}/manifest.json`
    }).promise()

    return JSON.parse(response.Body.toString())
  }

  async sendBackupNotification(type, status, backupId, error = null) {
    const notification = {
      type: 'backup_notification',
      backupType: type,
      status,
      backupId,
      timestamp: new Date().toISOString(),
      error: error?.message
    }

    // Send to monitoring/alerting system
    await this.sendNotification(notification)
  }

  async sendRestoreNotification(status, backupId, components, error = null) {
    const notification = {
      type: 'restore_notification',
      status,
      backupId,
      components,
      timestamp: new Date().toISOString(),
      error: error?.message
    }

    await this.sendNotification(notification)
  }

  // Utility methods
  async createTarArchive(sourceDir, excludePatterns = []) {
    const tar = require('tar')
    const stream = tar.create({
      gzip: true,
      cwd: sourceDir,
      filter: (path) => {
        return !excludePatterns.some(pattern => path.includes(pattern))
      }
    }, ['.'])

    return stream
  }

  async directoryExists(dir) {
    const fs = require('fs').promises
    try {
      const stats = await fs.stat(dir)
      return stats.isDirectory()
    } catch {
      return false
    }
  }

  async readFile(path) {
    const fs = require('fs').promises
    try {
      return await fs.readFile(path, 'utf8')
    } catch (error) {
      console.warn(`Could not read file ${path}:`, error.message)
      return null
    }
  }
}

export const backupManager = new BackupManager()
```
:::

### Disaster Recovery Procedures

Implement comprehensive disaster recovery planning and automated failover systems:

::: example
**Disaster Recovery Implementation**

```javascript
// disaster-recovery/recoveryManager.js
class DisasterRecoveryManager {
  constructor() {
    this.recoveryProcedures = new Map()
    this.healthChecks = new Map()
    this.recoverySteps = []
    this.currentStatus = 'healthy'
  }

  initializeDisasterRecovery() {
    this.setupHealthChecks()
    this.defineRecoveryProcedures()
    this.startMonitoring()
    console.log('Disaster recovery system initialized')
  }

  setupHealthChecks() {
    // Database health check
    this.healthChecks.set('database', async () => {
      try {
        const db = require('../database/connection')
        await db.query('SELECT 1')
        return { status: 'healthy', timestamp: Date.now() }
      } catch (error) {
        return { status: 'unhealthy', error: error.message, timestamp: Date.now() }
      }
    })

    // API health check
    this.healthChecks.set('api', async () => {
      try {
        const response = await fetch(`${process.env.API_URL}/health`)
        if (response.ok) {
          return { status: 'healthy', timestamp: Date.now() }
        }
        return { status: 'unhealthy', error: `API returned ${response.status}`, timestamp: Date.now() }
      } catch (error) {
        return { status: 'unhealthy', error: error.message, timestamp: Date.now() }
      }
    })

    // External services health check
    this.healthChecks.set('external-services', async () => {
      const services = ['redis', 'elasticsearch', 'monitoring']
      const results = await Promise.allSettled(
        services.map(service => this.checkExternalService(service))
      )

      const failures = results.filter(result => result.status === 'rejected')
      if (failures.length === 0) {
        return { status: 'healthy', timestamp: Date.now() }
      }

      return {
        status: 'unhealthy',
        error: `${failures.length} services failed`,
        details: failures,
        timestamp: Date.now()
      }
    })
  }

  defineRecoveryProcedures() {
    // Database recovery procedure
    this.recoveryProcedures.set('database-failure', [
      {
        name: 'Switch to read replica',
        execute: async () => {
          console.log('Switching to database read replica...')
          process.env.DATABASE_URL = process.env.DATABASE_REPLICA_URL
          await this.validateDatabaseConnection()
        }
      },
      {
        name: 'Restore from latest backup',
        execute: async () => {
          console.log('Restoring database from latest backup...')
          const { backupManager } = require('../backup/backupManager')
          const latestBackup = await backupManager.getLatestBackup('database')
          await backupManager.restoreFromBackup(latestBackup.id, ['database'])
        }
      },
      {
        name: 'Notify operations team',
        execute: async () => {
          await this.sendCriticalAlert('Database failure - switched to backup')
        }
      }
    ])

    // Application recovery procedure
    this.recoveryProcedures.set('application-failure', [
      {
        name: 'Restart application instances',
        execute: async () => {
          console.log('Restarting application instances...')
          await this.restartApplicationInstances()
        }
      },
      {
        name: 'Scale up instances',
        execute: async () => {
          console.log('Scaling up application instances...')
          await this.scaleApplicationInstances(2)
        }
      },
      {
        name: 'Enable maintenance mode',
        execute: async () => {
          console.log('Enabling maintenance mode...')
          await this.enableMaintenanceMode()
        }
      }
    ])

    // Network/connectivity recovery
    this.recoveryProcedures.set('network-failure', [
      {
        name: 'Switch to backup CDN',
        execute: async () => {
          console.log('Switching to backup CDN...')
          await this.switchToBackupCDN()
        }
      },
      {
        name: 'Route traffic to secondary region',
        execute: async () => {
          console.log('Routing traffic to secondary region...')
          await this.routeToSecondaryRegion()
        }
      }
    ])
  }

  startMonitoring() {
    // Run health checks every 30 seconds
    setInterval(async () => {
      await this.performHealthChecks()
    }, 30000)

    // Deep health check every 5 minutes
    setInterval(async () => {
      await this.performDeepHealthCheck()
    }, 300000)
  }

  async performHealthChecks() {
    const results = new Map()

    for (const [name, healthCheck] of this.healthChecks) {
      try {
        const result = await Promise.race([
          healthCheck(),
          this.timeout(10000) // 10 second timeout
        ])
        results.set(name, result)
      } catch (error) {
        results.set(name, {
          status: 'unhealthy',
          error: error.message,
          timestamp: Date.now()
        })
      }
    }

    await this.processHealthResults(results)
  }

  async processHealthResults(results) {
    const failures = Array.from(results.entries())
      .filter(([_, result]) => result.status === 'unhealthy')

    if (failures.length === 0) {
      if (this.currentStatus !== 'healthy') {
        console.log('System recovered - all health checks passing')
        await this.sendRecoveryNotification()
        this.currentStatus = 'healthy'
      }
      return
    }

    console.log(`Health check failures detected: ${failures.length}`)
    
    // Determine recovery strategy based on failures
    const recoveryStrategy = this.determineRecoveryStrategy(failures)
    
    if (recoveryStrategy) {
      await this.executeRecoveryProcedure(recoveryStrategy)
    }
  }

  determineRecoveryStrategy(failures) {
    const failureTypes = failures.map(([name, _]) => name)

    if (failureTypes.includes('database')) {
      return 'database-failure'
    }

    if (failureTypes.includes('api')) {
      return 'application-failure'
    }

    if (failureTypes.includes('external-services')) {
      return 'network-failure'
    }

    return null
  }

  async executeRecoveryProcedure(procedureName) {
    console.log(`Executing recovery procedure: ${procedureName}`)
    
    const procedure = this.recoveryProcedures.get(procedureName)
    if (!procedure) {
      console.error(`Recovery procedure not found: ${procedureName}`)
      return
    }

    this.currentStatus = 'recovering'

    for (const [index, step] of procedure.entries()) {
      try {
        console.log(`Executing step ${index + 1}: ${step.name}`)
        await step.execute()
        console.log(`Step ${index + 1} completed successfully`)
      } catch (error) {
        console.error(`Step ${index + 1} failed:`, error)
        
        // Continue with next step or abort based on step criticality
        if (step.critical !== false) {
          console.log('Critical step failed, aborting recovery procedure')
          await this.sendCriticalAlert(`Recovery procedure failed at step: ${step.name}`)
          break
        }
      }
    }
  }

  async performDeepHealthCheck() {
    console.log('Performing deep health check...')

    const checks = {
      diskSpace: await this.checkDiskSpace(),
      memoryUsage: await this.checkMemoryUsage(),
      cpuUsage: await this.checkCPUUsage(),
      networkLatency: await this.checkNetworkLatency(),
      dependencyVersions: await this.checkDependencyVersions()
    }

    const issues = Object.entries(checks)
      .filter(([_, result]) => !result.healthy)

    if (issues.length > 0) {
      console.log(`Deep health check found ${issues.length} issues`)
      await this.sendMaintenanceAlert(issues)
    }
  }

  // Recovery action implementations
  async restartApplicationInstances() {
    // Implementation depends on deployment platform
    // Example for Docker/Kubernetes
    const { exec } = require('child_process')
    
    return new Promise((resolve, reject) => {
      exec('kubectl rollout restart deployment/react-app', (error, stdout, stderr) => {
        if (error) {
          reject(error)
        } else {
          resolve(stdout)
        }
      })
    })
  }

  async scaleApplicationInstances(replicas) {
    const { exec } = require('child_process')
    
    return new Promise((resolve, reject) => {
      exec(`kubectl scale deployment/react-app --replicas=${replicas}`, (error, stdout, stderr) => {
        if (error) {
          reject(error)
        } else {
          resolve(stdout)
        }
      })
    })
  }

  async enableMaintenanceMode() {
    // Set maintenance mode flag
    process.env.MAINTENANCE_MODE = 'true'
    
    // Update load balancer configuration
    // Implementation depends on infrastructure
  }

  async sendCriticalAlert(message) {
    const alert = {
      severity: 'critical',
      message,
      timestamp: new Date().toISOString(),
      component: 'disaster-recovery'
    }

    // Send to multiple channels
    await Promise.allSettled([
      this.sendSlackAlert(alert),
      this.sendEmailAlert(alert),
      this.sendPagerDutyAlert(alert)
    ])
  }

  timeout(ms) {
    return new Promise((_, reject) => {
      setTimeout(() => reject(new Error('Health check timeout')), ms)
    })
  }
}

export const recoveryManager = new DisasterRecoveryManager()
```
:::

::: tip
**Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO)**

Define clear RTO and RPO targets for different failure scenarios:
- **Critical systems**: RTO < 15 minutes, RPO < 5 minutes
- **Standard systems**: RTO < 1 hour, RPO < 15 minutes
- **Non-critical systems**: RTO < 4 hours, RPO < 1 hour

Test recovery procedures regularly to ensure they meet these objectives.
:::

::: caution
**Security During Recovery**

Maintain security standards during disaster recovery:
- Use secure communication channels for coordination
- Validate backup integrity before restoration
- Implement emergency access controls with full audit trails
- Review and rotate credentials after recovery events
- Document all recovery actions for post-incident analysis
:::

::: note
**Testing Recovery Procedures**

Regularly test disaster recovery procedures through:
- Scheduled disaster recovery drills
- Chaos engineering experiments
- Backup restoration verification
- Failover system testing
- Recovery time measurement and optimization
:::

Operational excellence requires comprehensive preparation for various failure scenarios while maintaining security and performance standards throughout the recovery process. The strategies covered in this section enable teams to respond effectively to incidents while minimizing downtime and maintaining service quality during recovery operations.
