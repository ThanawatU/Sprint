<template>
    <div>
        <div class="flex justify-center min-h-screen py-8">
            <div class="flex w-full max-w-6xl mx-4 overflow-hidden bg-white border border-gray-300 rounded-lg shadow-lg">
                <ProfileSidebar />

                <main class="flex-1 p-8 bg-gray-50/50">
                    <div class="max-w-4xl mx-auto">
                        <div class="mb-8 border-b pb-4">
                            <h1 class="text-2xl font-bold text-gray-800">ขอข้อมูลประวัติการใช้งาน</h1>
                            <p class="text-gray-600 mt-1">
                                ยื่นคำขอเพื่อดาวน์โหลดข้อมูลประวัติการทำรายการของคุณ ระบบจะส่งคำขอไปยังผู้ดูแลระบบเพื่อพิจารณาอนุมัติ
                            </p>
                        </div>

                        <div class="bg-white p-6 rounded-lg border border-gray-200 shadow-sm mb-8">
                            <h2 class="text-lg font-semibold text-gray-800 mb-4">ยื่นคำขอข้อมูลใหม่</h2>
                            <form @submit.prevent="submitRequest" class="space-y-4">
                                
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label class="block mb-1 text-sm font-medium text-gray-700">รูปแบบไฟล์<span class="text-red-500">*</span></label>
                                        <select v-model="form.format" required class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500">
                                            <option value="CSV">CSV</option>
                                            <option value="JSON">JSON</option>
                                            <option value="PDF">PDF</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label class="block mb-1 text-sm font-medium text-gray-700">ช่วงวันที่ (ไม่บังคับ)</label>
                                        <div class="flex gap-2 items-center">
                                            <input type="date" v-model="form.dateFrom" class="w-full px-2 py-2 border border-gray-300 rounded-md text-sm" />
                                            <span class="text-gray-500">-</span>
                                            <input type="date" v-model="form.dateTo" class="w-full px-2 py-2 border border-gray-300 rounded-md text-sm" />
                                        </div>
                                    </div>
                                </div>

                                <div>
                                    <label class="block mb-1 text-sm font-medium text-gray-700">เหตุผลในการขอข้อมูล <span class="text-red-500">*</span></label>
                                    <textarea 
                                        v-model="form.reason" 
                                        required 
                                        rows="3" 
                                        placeholder="เขียนเหตุผลที่คุณต้องการขอข้อมูล"
                                        class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                                    ></textarea>
                                </div>

                                <div class="flex justify-end">
                                    <button 
                                        type="submit" 
                                        :disabled="isSubmitting"
                                        class="px-6 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:bg-blue-400 flex items-center gap-2"
                                    >
                                        <svg v-if="isSubmitting" class="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" class="opacity-25"></circle>
                                            <path d="M4 12a8 8 0 018-8v8H4z" fill="currentColor" class="opacity-75"></path>
                                        </svg>
                                        {{ isSubmitting ? 'กำลังส่งคำขอ' : 'ส่งคำขอข้อมูล' }}
                                    </button>
                                </div>
                            </form>
                        </div>

                        <div>
                            <h2 class="text-lg font-semibold text-gray-800 mb-4">ประวัติคำขอของฉัน</h2>
                            <div class="bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden">
                                <table class="w-full text-sm text-left text-gray-600">
                                    <thead class="text-xs text-gray-700 uppercase bg-gray-50 border-b">
                                        <tr>
                                            <th class="px-4 py-3">วันที่ขอ</th>
                                            <th class="px-4 py-3">เหตุผล</th>
                                            <th class="px-4 py-3">รูปแบบ</th>
                                            <th class="px-4 py-3">สถานะ</th>
                                            <th class="px-4 py-3 text-right">จัดการ</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr v-for="req in requests" :key="req.id" class="border-b hover:bg-gray-50">
                                            <td class="px-4 py-3 whitespace-nowrap">{{ formatDate(req.createdAt) }}</td>
                                            <td class="px-4 py-3 max-w-[200px] truncate" :title="req.filters?.reason || '-'">
                                                {{ req.filters?.reason || '-' }}
                                            </td>
                                            <td class="px-4 py-3 font-medium">{{ req.format }}</td>
                                            <td class="px-4 py-3">
                                                <span :class="getStatusClass(req.status)" class="px-2 py-1 text-xs font-semibold rounded-full">
                                                    {{ req.status }}
                                                </span>
                                                <div v-if="req.status === 'REJECTED' && req.rejectionReason" class="text-xs text-red-500 mt-1 truncate max-w-[150px]" :title="req.rejectionReason">
                                                    เหตุผล: {{ req.rejectionReason }}
                                                </div>
                                            </td>
                                            <td class="px-4 py-3 text-right">
                                                <button 
                                                    v-if="req.status === 'COMPLETED' || req.status === 'APPROVED'" 
                                                    @click="downloadLog(req.id, req.format)"
                                                    class="text-blue-600 hover:text-blue-800 font-medium text-xs border border-blue-600 px-3 py-1 rounded"
                                                >
                                                    ดาวน์โหลด
                                                </button>
                                                <span v-else class="text-gray-400 text-xs">-</span>
                                            </td>
                                        </tr>
                                        <tr v-if="requests.length === 0">
                                            <td colspan="5" class="px-4 py-8 text-center text-gray-500">
                                                ยังไม่มีประวัติการขอข้อมูล
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>
                </main>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import ProfileSidebar from '~/components/ProfileSidebar.vue';
import { useAuth } from '~/composables/useAuth';
import { useToast } from '~/composables/useToast';
import { useRuntimeConfig } from '#app';
import dayjs from 'dayjs';

definePageMeta({ middleware: 'auth' });

const config = useRuntimeConfig();
const { user } = useAuth();
const { toast } = useToast();

const isSubmitting = ref(false);
const requests = ref([]);

// form state
const form = reactive({
    format: 'CSV',
    reason: '',
    dateFrom: '',
    dateTo: ''
});

function getAuthHeaders() {
    const token = useCookie("token").value;
    return token ? { Authorization: `Bearer ${token}` } : {};
}

function formatDate(date) {
    if (!date) return "-";
    return dayjs(date).format("D MMM YYYY HH:mm");
}

function getStatusClass(status) {
    switch (status) {
        case 'APPROVED':
        case 'COMPLETED': return 'bg-green-100 text-green-700';
        case 'REJECTED': return 'bg-red-100 text-red-700';
        case 'FAILED': return 'bg-gray-100 text-gray-700';
        default: return 'bg-yellow-100 text-yellow-800'; // PENDING, PROCESSING
    }
}

async function fetchMyRequests() {
    try {
        // ใช้ fetch ตรงไปที่ backend พร้อมส่ง Header
        const response = await $fetch("/logs/exports", {
            baseURL: config.public.apiBase,
            headers: getAuthHeaders(),
            query: { limit: 50 } // ดึงมา 50 รายการล่าสุด
        });
        
        if (response.success) {
            requests.value = response.data;
        }
    } catch (error) {
        console.error("Fetch requests error:", error);
    }
}

async function submitRequest() {
    if (!form.reason.trim()) {
        toast.error('แจ้งเตือน', 'กรุณาระบุเหตุผลในการขอข้อมูล');
        return;
    }

    isSubmitting.value = true;
    try {
        let dateFromFilter = undefined;
        let dateToFilter = undefined;
        if (form.dateFrom) dateFromFilter = `${form.dateFrom}T00:00:00.000Z`;
        if (form.dateTo) dateToFilter = `${form.dateTo}T23:59:59.999Z`;

        const payload = {
            logType: 'AuditLog',
            format: form.format,
            filters: {
                reason: form.reason, 
                userId: user.value?.id,
                dateFrom: dateFromFilter,
                dateTo: dateToFilter
            }
        };

        const response = await $fetch("/logs/exports", {
            method: "POST",
            baseURL: config.public.apiBase,
            headers: getAuthHeaders(),
            body: payload
        });

        if (response.success) {
            toast.success('สำเร็จ', 'ส่งคำขอเรียบร้อย กรุณารอการพิจารณา');
            form.reason = '';
            form.dateFrom = '';
            form.dateTo = '';
            await fetchMyRequests();
        }
    } catch (error) {
        console.error("Submit error:", error);
        toast.error('เกิดข้อผิดพลาด', error.response?._data?.message || 'ไม่สามารถส่งคำขอได้');
    } finally {
        isSubmitting.value = false;
    }
}

async function downloadLog(id, format) {
    try {
        toast.info('กำลังดาวน์โหลด', 'กรุณารอสักครู่ระบบกำลังดึงไฟล์...');
        const blob = await $fetch(`/logs/exports/${id}/download`, {
        baseURL: config.public.apiBase,
        headers: getAuthHeaders(),
        responseType: 'blob'
        });

        let extension = "csv";
        if (format === "JSON") extension = "json";
        if (format === "PDF") extension = "pdf";

        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `UserRequest_${id}_${dayjs().format('YYYYMMDD')}.${extension}`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        a.remove();
        
        toast.success('สำเร็จ', 'ดาวน์โหลดไฟล์เรียบร้อยแล้ว');
    } catch (error) {
        console.error("Download Error:", error);
        toast.error('เกิดข้อผิดพลาด', 'ไม่สามารถดาวน์โหลดไฟล์ได้');
    }
}

onMounted(() => {
    fetchMyRequests();
});
</script>