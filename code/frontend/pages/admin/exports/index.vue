<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6 bg-gray-50 min-h-screen">
      <div class="mb-8 flex justify-between items-end">
        <div>
          <h1 class="text-2xl font-semibold text-gray-800">จัดการคำขอ Export Logs</h1>
          <p class="text-sm text-gray-500 mt-1">ตรวจสอบและอนุมัติการขอข้อมูลประวัติการใช้งานจากผู้ใช้</p>
        </div>
        
        <div class="flex items-center gap-2">
          <label class="text-sm font-medium text-gray-700">สถานะ:</label>
          <select v-model="statusFilter" @change="fetchRequests" class="border px-3 py-2 rounded-md text-sm bg-white">
            <option value="">ทั้งหมด</option>
            <option value="PENDING">รอดำเนินการ</option>
            <option value="APPROVED">อนุมัติแล้ว</option>
            <option value="REJECTED">ปฏิเสธแล้ว</option>
          </select>
        </div>
      </div>

      <div class="bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-sm text-left text-gray-600">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 border-b">
              <tr>
                <th class="px-4 py-3 w-[150px]">วันที่ขอ</th>
                <th class="px-4 py-3 w-[200px]">ผู้ขอ</th>
                <th class="px-4 py-3 w-[250px]">เหตุผลที่ขอ</th>
                <th class="px-4 py-3 w-[100px]">ประเภทไฟล์</th>
                <th class="px-4 py-3 w-[120px]">สถานะ</th>
                <th class="px-4 py-3 text-right">จัดการ</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="req in requests" :key="req.id" class="border-b hover:bg-gray-50">
                <td class="px-4 py-3">{{ formatDate(req.createdAt) }}</td>
                <td class="px-4 py-3">
                  <div class="font-medium text-gray-900">{{ req.requestedBy?.email || 'Unknown User' }}</div>
                  <div class="text-xs text-gray-500">ID: {{ req.requestedById }}</div>
                </td>
                <td class="px-4 py-3">
                  <p class="truncate max-w-[200px]" :title="req.filters?.reason || '-'">
                    {{ req.filters?.reason || '-' }}
                  </p>
                </td>
                <td class="px-4 py-3">
                  <div class="font-medium">{{ req.logType }}</div>
                  <div class="text-xs text-gray-500">{{ req.format }}</div>
                </td>
                <td class="px-4 py-3">
                  <span :class="getStatusClass(req.status)" class="px-2 py-1 text-xs font-semibold rounded-full">
                    {{ req.status }}
                  </span>
                  <div v-if="req.status === 'REJECTED' && req.rejectionReason" class="text-xs text-red-500 mt-1 truncate max-w-[120px]" :title="req.rejectionReason">
                    เหตุผล: {{ req.rejectionReason }}
                  </div>
                </td>
                <td class="px-4 py-3 text-right">
                  <div v-if="req.status === 'PENDING'" class="flex justify-end gap-2">
                    <button @click="handleApprove(req.id)" :disabled="processingId === req.id" class="text-white bg-green-600 hover:bg-green-700 px-3 py-1.5 rounded text-xs font-medium transition flex items-center gap-1 disabled:opacity-50">
                      <span v-if="processingId === req.id">กำลังสร้างไฟล์...</span>
                      <span v-else>อนุมัติ</span>
                    </button>
                    <button @click="openRejectModal(req.id)" :disabled="processingId === req.id" class="text-white bg-red-600 hover:bg-red-700 px-3 py-1.5 rounded text-xs font-medium transition disabled:opacity-50">
                      ปฏิเสธ
                    </button>
                  </div>
                  
                  <div v-else-if="req.status === 'APPROVED'" class="flex justify-end items-center gap-2">
                    <span class="text-gray-400 text-xs hidden sm:inline-block" :title="req.reviewedBy?.email">
                      รีวิวโดย: {{ req.reviewedBy?.email || 'System' }}
                    </span>
                    <button 
                      @click="downloadLog(req.id, req.format)"
                      class="text-blue-600 hover:text-blue-800 font-medium text-xs border border-blue-600 px-3 py-1 rounded bg-blue-50 transition flex items-center gap-1"
                    >
                      <i class="fa-solid fa-download"></i> ดาวน์โหลด
                    </button>
                  </div>

                  <span v-else class="text-gray-400 text-xs">
                    รีวิวโดย: {{ req.reviewedBy?.email || 'System' }}
                  </span>
                </td>
              </tr>
              <tr v-if="requests.length === 0">
                <td colspan="6" class="px-4 py-8 text-center text-gray-500">
                  ไม่พบรายการคำขอ
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div v-if="showRejectModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-10">
        <div class="bg-white rounded-lg shadow-lg w-full max-w-md p-6">
          <h2 class="text-lg font-bold text-gray-900 mb-4">ระบุเหตุผลที่ปฏิเสธ</h2>
          <textarea 
            v-model="rejectionReason" 
            rows="3" 
            placeholder="เขียนเหตุผลที่ปฏิเสธคำขอนี้"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-red-500 focus:border-red-500"
          ></textarea>
          <div class="flex justify-end gap-3 mt-4">
            <button @click="closeRejectModal" class="px-4 py-2 text-gray-600 bg-gray-100 rounded hover:bg-gray-200">
              ยกเลิก
            </button>
            <button 
              @click="submitReject" 
              :disabled="!rejectionReason.trim() || isRejecting"
              class="px-4 py-2 text-white bg-red-600 rounded hover:bg-red-700 disabled:opacity-50"
            >
              {{ isRejecting ? 'กำลังบันทึก' : 'ยืนยันการปฏิเสธ' }}
            </button>
          </div>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import AdminHeader from '~/components/admin/AdminHeader.vue';
import AdminSidebar from '~/components/admin/AdminSidebar.vue';
import { useRuntimeConfig } from '#app';
import { useToast } from '~/composables/useToast';
import dayjs from 'dayjs';

definePageMeta({ middleware: ['admin-auth'] });

const config = useRuntimeConfig();
const { toast } = useToast();

const requests = ref([]);
const statusFilter = ref('');
const processingId = ref(null);

const showRejectModal = ref(false);
const rejectingId = ref(null);
const rejectionReason = ref('');
const isRejecting = ref(false);

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
    case 'APPROVED': return 'bg-green-100 text-green-700';
    case 'REJECTED': return 'bg-red-100 text-red-700';
    default: return 'bg-yellow-100 text-yellow-800';
  }
}

async function fetchRequests() {
  try {
    const query = { limit: 50 };
    if (statusFilter.value === 'APPROVED') {
      query.status = statusFilter.value; 
    } else if (statusFilter.value) {
      query.status = statusFilter.value;
    }

    const response = await $fetch("/logs/exports", {
      baseURL: config.public.apiBase,
      headers: getAuthHeaders(),
      query
    });

    if (response.success) {
      requests.value = response.data;
    }
  } catch (error) {
    console.error("Fetch requests error:", error);
    toast.error("ข้อผิดพลาด", "ไม่สามารถดึงข้อมูลรายการได้");
  }
}

async function handleApprove(id) {
  if (!confirm("คุณยืนยันที่จะอนุมัติและสร้างไฟล์ให้ผู้ใช้คนนี้หรือไม่?")) return;
  
  processingId.value = id;
  toast.info("กำลังประมวลผล", "กำลังอนุมัติและสร้างไฟล์ Log โปรดรอสักครู่");

  try {
    const response = await $fetch(`/logs/exports/${id}/review`, {
      method: "PATCH",
      baseURL: config.public.apiBase,
      headers: getAuthHeaders(),
      body: { status: "APPROVED" }
    });

    if (response.success) {
      toast.success("สำเร็จ", "อนุมัติและสร้างไฟล์เรียบร้อยแล้ว");
      fetchRequests(); // Refresh data
    }
  } catch (error) {
    console.error("Approve error:", error);
    toast.error("ข้อผิดพลาด", error.response?._data?.message || "ไม่สามารถอนุมัติได้");
  } finally {
    processingId.value = null;
  }
}

function openRejectModal(id) {
  rejectingId.value = id;
  rejectionReason.value = '';
  showRejectModal.value = true;
}

function closeRejectModal() {
  showRejectModal.value = false;
  rejectingId.value = null;
  rejectionReason.value = '';
}

async function submitReject() {
  if (!rejectionReason.value.trim()) return;

  isRejecting.value = true;
  processingId.value = rejectingId.value;

  try {
    const response = await $fetch(`/logs/exports/${rejectingId.value}/review`, {
      method: "PATCH",
      baseURL: config.public.apiBase,
      headers: getAuthHeaders(),
      body: { 
        status: "REJECTED",
        rejectionReason: rejectionReason.value
      }
    });

    if (response.success) {
      toast.success("สำเร็จ", "ปฏิเสธคำขอเรียบร้อยแล้ว");
      closeRejectModal();
      fetchRequests();
    }
  } catch (error) {
    console.error("Reject error:", error);
    toast.error("ข้อผิดพลาด", error.response?._data?.message || "ไม่สามารถปฏิเสธคำขอได้");
  } finally {
    isRejecting.value = false;
    processingId.value = null;
  }
}

onMounted(() => {
  fetchRequests();
});
</script>