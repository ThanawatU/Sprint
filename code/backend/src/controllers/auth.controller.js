const asyncHandler = require('express-async-handler');
const { signToken } = require("../utils/jwt");
const userService = require("../services/user.service");
const ApiError = require('../utils/ApiError');
const { logAudit } = require('../services/audit.service');
const { logLogin } = require('../utils/accessLog');
const { prisma } = require("../utils/prisma"); // adjust path if needed

const login = asyncHandler(async (req, res) => {
    const { email, username, password } = req.body;

    let user;
    // Check Whether Login by Email or Username
    if (email) {
        user = await userService.getUserByEmail(email);
    } else if (username) {
        user = await userService.getUserByUsername(username);
    }


    if (user && !user.isActive) {
        await logAudit({
            userId: user.id,
            role: user.role,
            action: 'LOGIN_ATTEMPT',
            entity: 'User',
            entityId: user.id,
            req,
            metadata: { reason: 'Account deactivated' }
        });
        throw new ApiError(401, "Your account has been deactivated.");
    }

    const passwordIsValid = user ? await userService.comparePassword(user, password) : false;
    if (!user || !passwordIsValid) {
        await logAudit({
            userId: user?.id,
            role: user?.role,
            action: 'LOGIN_ATTEMPT',
            entity: 'User',
            entityId: user ? user.id : null,
            req,
            metadata: { reason: "Invalid Password or User doesn't exist" }
        });
        throw new ApiError(401, "Invalid credentials");
    }


    const token = signToken({ sub: user.id, role: user.role });
    const {
        password:_,
        gender,
        phoneNumber,
        otpCode,
        nationalIdNumber,
        nationalIdPhotoUrl,
        nationalIdExpiryDate,
        selfiePhotoUrl,
        isVerified,
        isActive,
        lastLogin,
        createdAt,
        updatedAt,
        username:__,
        email:___,
        ...safeUser
    } = user;

    await logAudit({
        userId: user.id,
        role: user.role,
        action: 'LOGIN_SUCCESS',
        entity: 'User',
        entityId: user.id,
        req
    });

    // บันทึก login ใน AccessLog
    await logLogin({
        userId: user.id,
        ipAddress: req.ip,
        userAgent: req.get('user-agent'),
        sessionId: req.requestId
    });

    res.status(200).json({
        success: true,
        message: "Login successful",
        data: { token, user: safeUser }
    });
});

const changePassword = asyncHandler(async (req, res) => {
    const userId = req.user.sub;
    const { currentPassword, newPassword } = req.body;

    const result = await userService.updatePassword(userId, currentPassword, newPassword);

    if (!result.success) {
        if (result.error === 'INCORRECT_PASSWORD') {
            throw new ApiError(401, 'Incorrect current password.');
        }

        await logAudit({
            userId: userId,
            role: req.user.role,
            action: 'PASSWORD_CHANGE_FAILED',
            entity: 'User',
            entityId: userId,
            req,
            metadata: { reason: "Failed to update password" }
        });
        throw new ApiError(500, 'Could not update password.');
    }

    await logAudit({
        userId: userId,
        role: req.user.role,
        action: 'PASSWORD_CHANGED',
        entity: 'User',
        entityId: userId,
        req
    });

    res.status(200).json({
        success: true,
        message: "Password changed successfully",
        data: null
    });
    
});

module.exports = { login, changePassword};