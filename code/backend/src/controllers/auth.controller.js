const asyncHandler = require('express-async-handler');
const { signToken } = require("../utils/jwt");
const userService = require("../services/user.service");
const ApiError = require('../utils/ApiError');
const { logAudit } = require('../services/audit.service');

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

    res.status(200).json({
        success: true,
        message: "Login successful",
        data: { token, user: safeUser }
    });
    await logAudit({
        action: 'LOGIN_SUCCESS',
        entity: 'User',
        entityId: user.id,
        req
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
            action: 'PASSWORD_CHANGE_FAILED',
            entity: 'User',
            entityId: userId,
            req,
            metadata: { reason: "Failed to update password" }
        });
        throw new ApiError(500, 'Could not update password.');
    }

    res.status(200).json({
        success: true,
        message: "Password changed successfully",
        data: null
    });
    await logAudit({
            action: 'PASSWORD_CHANGED',
            entity: 'User',
            entityId: user.id,
            req
    });
});

module.exports = { login, changePassword };