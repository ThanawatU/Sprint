<template>
  <div>
    <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
      <div class="mb-8">
        <h2 class="text-2xl font-bold text-gray-900">การเดินทางของฉัน</h2>
        <p class="mt-2 text-gray-600">จัดการและติดตามการเดินทางทั้งหมดของคุณ</p>
      </div>

      <div
        class="p-6 mb-8 bg-white border border-gray-300 rounded-lg shadow-md"
      >
        <div class="flex flex-wrap gap-2">
          <button
            v-for="tab in tabs"
            :key="tab.status"
            @click="activeTab = tab.status"
            :class="[
              'tab-button px-4 py-2 rounded-md font-medium',
              { active: activeTab === tab.status },
            ]"
          >
            {{ tab.label }} ({{ getTripCount(tab.status) }})
          </button>
        </div>
      </div>

      <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div class="lg:col-span-2">
          <div class="bg-white border border-gray-300 rounded-lg shadow-md">
            <div class="p-6 border-b border-gray-300">
              <h3 class="text-lg font-semibold text-gray-900">
                รายการการเดินทาง
              </h3>
            </div>

            <div v-if="isLoading" class="p-12 text-center text-gray-500">
              <p>กำลังโหลดข้อมูลการเดินทาง...</p>
            </div>

            <div v-else class="divide-y divide-gray-200">
              <div
                v-if="filteredTrips.length === 0"
                class="p-12 text-center text-gray-500"
              >
                <p>ไม่พบรายการเดินทางในหมวดหมู่นี้</p>
              </div>

              <div
                v-for="trip in filteredTrips"
                :key="trip.id"
                class="p-6 transition-colors duration-200 cursor-pointer trip-card hover:bg-gray-50"
                @click="toggleTripDetails(trip.id)"
              >
                <div class="flex items-start justify-between mb-4">
                  <div class="flex-1">
                    <div class="flex items-center justify-between">
                      <h4 class="text-lg font-semibold text-gray-900">
                        {{ trip.origin }} → {{ trip.destination }}
                      </h4>
                      <span
                        v-if="trip.status === 'pending'"
                        class="status-badge status-pending"
                        >รอดำเนินการ</span
                      >
                      <span
                        v-else-if="trip.status === 'confirmed'"
                        class="status-badge status-confirmed"
                        >ยืนยันแล้ว</span
                      >

                      <span
                        v-else-if="trip.status === 'completed'"
                        class="status-badge status-confirmed"
                      >
                        เสร็จสิ้น
                      </span>
                      <span
                        v-else-if="trip.status === 'rejected'"
                        class="status-badge status-rejected"
                        >ปฏิเสธ</span
                      >
                      <span
                        v-else-if="trip.status === 'cancelled'"
                        class="status-badge status-cancelled"
                        >ยกเลิก</span
                      >
                    </div>
                    <p class="mt-1 text-sm text-gray-600">
                      จุดนัดพบ: {{ trip.pickupPoint }}
                    </p>
                    <p class="text-sm text-gray-600">
                      วันที่: {{ trip.date }}
                      <span class="mx-2 text-gray-300">|</span>
                      เวลา: {{ trip.time }}
                      <span class="mx-2 text-gray-300">|</span>
                      ระยะเวลา: {{ trip.durationText }}
                      <span class="mx-2 text-gray-300">|</span>
                      ระยะทาง: {{ trip.distanceText }}
                    </p>
                  </div>
                </div>

                <div class="flex items-center mb-4 space-x-4">
                  <img
                    :src="trip.driver.image"
                    :alt="trip.driver.name"
                    class="object-cover w-12 h-12 rounded-full"
                  />
                  <div class="flex-1">
                    <h5 class="font-medium text-gray-900">
                      {{ trip.driver.name }}
                    </h5>
                    <div class="flex items-center">
                      <div class="flex text-sm text-yellow-400">
                        <span v-if="getDriverRating(trip.driverId).count">
                          {{
                            "★".repeat(
                              Math.round(getDriverRating(trip.driverId).avg),
                            )
                          }}
                          {{
                            "☆".repeat(
                              5 -
                                Math.round(getDriverRating(trip.driverId).avg),
                            )
                          }}
                        </span>

                        <span v-else> ☆☆☆☆☆ </span>
                      </div>

                      <span class="ml-2 text-sm text-gray-600">
                        <span v-if="getDriverRating(trip.driverId).count">
                          ⭐ {{ getDriverRating(trip.driverId).avg }} ({{
                            getDriverRating(trip.driverId).count
                          }}
                          รีวิว)
                        </span>

                        <span v-else class="text-gray-400">
                          ยังไม่มีรีวิว
                        </span>
                      </span>
                    </div>
                  </div>
                  <div class="text-right">
                    <div class="text-lg font-bold text-blue-600">
                      {{ trip.price }} บาท
                    </div>
                    <div class="text-sm text-gray-600">
                      จำนวน {{ trip.seats }} ที่นั่ง
                    </div>
                  </div>
                </div>

                <div
                  v-if="selectedTripId === trip.id"
                  class="pt-4 mt-4 mb-5 duration-300 border-t border-gray-300 animate-in slide-in-from-top"
                >
                  <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
                    <div>
                      <h5 class="mb-2 font-medium text-gray-900">
                        รายละเอียดเส้นทาง
                      </h5>
                      <ul class="space-y-1 text-sm text-gray-600">
                        <li>
                          • จุดเริ่มต้น:
                          <span class="font-medium text-gray-900">{{
                            trip.origin
                          }}</span>
                          <span v-if="trip.originAddress">
                            — {{ trip.originAddress }}</span
                          >
                        </li>

                        <template v-if="trip.stops && trip.stops.length">
                          <li class="mt-2 text-gray-700">
                            • จุดแวะระหว่างทาง ({{ trip.stops.length }} จุด):
                          </li>
                          <li v-for="(stop, idx) in trip.stops" :key="idx">
                              - จุดแวะ {{ idx + 1 }}: {{ stop }}
                          </li>
                        </template>

                        <li class="mt-1">
                          • จุดปลายทาง:
                          <span class="font-medium text-gray-900">{{
                            trip.destination
                          }}</span>
                          <span v-if="trip.destinationAddress">
                            — {{ trip.destinationAddress }}</span
                          >
                        </li>
                      </ul>
                    </div>
                    <div>
                      <h5 class="mb-2 font-medium text-gray-900">
                        รายละเอียดรถ
                      </h5>
                      <ul class="space-y-1 text-sm text-gray-600">
                        <li v-for="detail in trip.carDetails" :key="detail">
                          • {{ detail }}
                        </li>
                        <button
                          data-v-2f92c40d=""
                          class="px-4 py-2 text-sm text-red-600 transition duration-200 border border-red-300 rounded-md hover:bg-red-50"
                        >
                          ยกเลิกการจอง
                        </button>
                      </ul>
                      <div
                        v-if="driverReviews[trip.driverId]?.length"
                        class="mt-6"
                      >
                        <h5 class="mb-3 font-medium text-gray-900">
                          รีวิวของคนขับ
                        </h5>

                        <div class="space-y-3">
                          <div
                            v-for="review in driverReviews[trip.driverId]"
                            :key="review.id"
                            class="p-3 border rounded-md bg-gray-50"
                          >
                            <div class="flex items-center justify-between">
                              <div class="text-yellow-400">
                                {{ "★".repeat(review.rating)
                                }}{{ "☆".repeat(5 - review.rating) }}
                              </div>

                              <span class="text-xs text-gray-500">
                                {{
                                  dayjs(review.createdAt).format("D MMM YYYY")
                                }}
                              </span>
                            </div>

                            <p
                              v-if="review.comment"
                              class="mt-1 text-sm text-gray-700"
                            >
                              {{ review.comment }}
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="mt-4 space-y-4">
                    <div v-if="trip.conditions">
                      <h5 class="mb-2 font-medium text-gray-900">
                        เงื่อนไขการเดินทาง
                      </h5>
                      <p
                        class="p-3 text-sm text-gray-700 border border-gray-300 rounded-md bg-gray-50"
                      >
                        {{ trip.conditions }}
                      </p>
                    </div>

                    <div v-if="trip.photos && trip.photos.length > 0">
                      <h5 class="mb-2 font-medium text-gray-900">
                        รูปภาพรถยนต์
                      </h5>
                      <div class="grid grid-cols-3 gap-2 mt-2">
                        <div
                          v-for="(photo, index) in trip.photos.slice(0, 3)"
                          :key="index"
                        >
                          <img
                            :src="photo"
                            alt="Vehicle photo"
                            class="object-cover w-full transition-opacity rounded-lg shadow-sm cursor-pointer aspect-video hover:opacity-90"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div
                  class="flex justify-end space-x-3"
                  :class="{ 'mt-4': selectedTripId !== trip.id }"
                >
                  <!-- PENDING: ยกเลิกได้ + รายงาน-->
                  <button
                    v-if="trip.status === 'pending'"
                    @click.stop="openCancelModal(trip)"
                    class="px-4 py-2 text-sm text-red-600 transition duration-200 border border-red-300 rounded-md hover:bg-red-50"
                  >
                    ยกเลิกการจอง
                  </button>

                  <button
                    v-if="trip.status === 'pending' && !hasActiveReport(trip)"
                    @click.stop="openReportModal(trip)"
                    class="px-4 py-2 text-sm text-yellow-700 transition duration-200 border border-yellow-300 rounded-md hover:bg-yellow-50"
                  >
                    รายงานปัญหา
                  </button>

                  <button
                    v-if="trip.status === 'pending' && hasActiveReport(trip)"
                    @click.stop="router.push('/myHistory')"
                    class="px-4 py-2 text-sm text-gray-600 transition duration-200 border border-gray-400 rounded-md cursor-pointer hover:bg-gray-50"
                    title="รายงานไปแล้ว สามารถเพิ่มหลักฐานได้ที่ประวัติ"
                  >
                    ดูประวัติการรายงาน
                  </button>

                  <!-- CONFIRMED: เพิ่มปุ่มยกเลิก + คงปุ่มแชท+รายงาน -->
                  <template v-else-if="trip.status === 'confirmed'">
                    <button
                      v-if="!hasActiveReport(trip)"
                      @click.stop="openReportModal(trip)"
                      class="px-4 py-2 text-sm text-yellow-700 transition duration-200 border border-yellow-300 rounded-md hover:bg-yellow-50"
                    >
                      รายงานปัญหา
                    </button>

                    <button
                      v-if="hasActiveReport(trip)"
                      @click.stop="router.push('/myHistory')"
                      class="px-4 py-2 text-sm text-gray-600 transition duration-200 border border-gray-400 rounded-md cursor-pointer hover:bg-gray-50"
                      title="รายงานไปแล้ว สามารถเพิ่มหลักฐานได้ที่ประวัติ"
                    >
                      ดูประวัติการรายงาน
                    </button>

                    <button
                      @click.stop="openCancelModal(trip)"
                      class="px-4 py-2 text-sm text-red-600 transition duration-200 border border-red-300 rounded-md hover:bg-red-50"
                    >
                      ยกเลิกการจอง
                    </button>
                    <button
                      class="px-4 py-2 text-sm text-white transition duration-200 bg-blue-600 rounded-md hover:bg-blue-700"
                    >
                      แชทกับผู้ขับ
                    </button>
                  </template>

                  <!-- COMPLETED -->
                  <template v-else-if="trip.status === 'completed'">
                    <button
                      v-if="!reviewedBookings[trip.id]"
                      @click.stop="openReviewModal(trip)"
                      class="px-4 py-2 text-sm text-white bg-yellow-500 rounded-md hover:bg-yellow-600"
                    >
                      รีวิวคนขับ
                    </button>

                    <span
                      v-else
                      disabled
                      class="px-4 py-2 text-sm text-green-600 border border-green-300 rounded-md"
                    >
                      รีวิวแล้ว
                    </span>

                    <!-- ปุ่มรายงาน -->
                    <button
                      v-if="!hasActiveReport(trip)"
                      @click.stop="openReportModal(trip)"
                      class="px-4 py-2 text-sm text-yellow-700 transition duration-200 border border-yellow-300 rounded-md hover:bg-yellow-50"
                    >
                      รายงานปัญหา
                    </button>
                  </template>

                  <!-- REJECTED / CANCELLED: ลบได้ -->
                  <template v-else-if="trip.status === 'rejected'">
                    <button
                      v-if="!hasActiveReport(trip)"
                      @click.stop="openReportModal(trip)"
                      class="px-3 py-1.5 text-xs text-yellow-700 border border-yellow-300 rounded-md hover:bg-yellow-50"
                    >
                      รายงานปัญหา
                    </button>

                    <button
                      v-if="hasActiveReport(trip)"
                      @click.stop="router.push('/myHistory')"
                      class="px-3 py-1.5 text-xs text-gray-600 border border-gray-400 rounded-md cursor-pointer hover:bg-gray-50"
                      title="รายงานไปแล้ว สามารถเพิ่มหลักฐานได้ที่ประวัติ"
                    >
                      ดูประวัติ
                    </button>

                    <button
                      @click.stop="openConfirmModal(trip, 'delete')"
                      class="px-3 py-1.5 text-xs text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
                    >
                      ลบรายการ
                    </button>
                  </template>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="lg:col-span-1">
          <div
            class="sticky overflow-hidden bg-white border border-gray-300 rounded-lg shadow-md top-8"
          >
            <div class="p-6 border-b border-gray-300">
              <h3 class="text-lg font-semibold text-gray-900">แผนที่เส้นทาง</h3>
            </div>
            <div ref="mapContainer" id="map" class="h-96"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- REVIEW MODAL -->
    <div
      v-if="showReviewModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
      @click.self="showReviewModal = false"
    >
      <div class="w-full max-w-2xl p-6 bg-white rounded-lg shadow-xl">
        <h3 class="text-lg font-semibold text-gray-900">รีวิวการเดินทาง</h3>
        <p class="mt-1 text-sm text-gray-600">
          กรุณาให้คะแนนและความคิดเห็นเกี่ยวกับคนขับ
        </p>

        <div class="mt-4 space-y-4">
          <!-- Rating -->
          <div>
            <label class="block mb-2 text-sm text-gray-700"> ให้คะแนน </label>

            <div class="flex text-3xl">
              <span
                v-for="i in 5"
                :key="i"
                @click="rating = i"
                class="cursor-pointer"
                :class="i <= rating ? 'text-yellow-400' : 'text-gray-300'"
              >
                ★
              </span>
            </div>
          </div>

          <!-- Comment -->
          <div>
            <label class="block mb-1 text-sm text-gray-700">
              ความคิดเห็น
            </label>

            <textarea
              v-model="comment"
              rows="4"
              class="w-full px-3 py-2 border border-gray-300 rounded-md"
              placeholder="เขียนความคิดเห็นเกี่ยวกับการเดินทาง..."
            ></textarea>
          </div>

          <!-- Upload Images -->
          <div>
            <label class="block mb-1 text-sm text-gray-700">
              แนบรูปภาพ (ไม่เกิน 3 รูป)
            </label>

            <input
              type="file"
              multiple
              accept="image/*"
              @change="handleReviewImages"
              class="w-full text-sm"
            />

            <div
              v-if="reviewImages.length"
              class="grid grid-cols-2 gap-3 mt-3 md:grid-cols-3"
            >
              <div
                v-for="(img, index) in reviewImages"
                :key="index"
                class="relative"
              >
                <img
                  :src="img.preview"
                  class="object-cover w-full border border-gray-300 rounded-lg aspect-video"
                />

                <button
                  @click="removeReviewImage(index)"
                  class="absolute top-1 right-1 px-2 py-1 text-xs text-white bg-red-500 rounded-full hover:bg-red-600"
                >
                  ✕
                </button>
              </div>
            </div>
          </div>
        </div>

        <div class="flex justify-end gap-2 mt-6">
          <button
            @click="showReviewModal = false"
            class="px-4 py-2 text-sm text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
          >
            ปิด
          </button>

          <button
            @click="submitReview"
            :disabled="isSubmittingReview"
            class="px-4 py-2 text-sm text-white bg-yellow-600 rounded-md hover:bg-yellow-700 disabled:opacity-50"
          >
            {{ isSubmittingReview ? "กำลังส่ง..." : "ส่งรีวิว" }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal: เลือกเหตุผลการยกเลิก -->
    <div
      v-if="isCancelModalVisible"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
      @click.self="closeCancelModal"
    >
      <div class="w-full max-w-md p-6 bg-white rounded-lg shadow-xl">
        <h3 class="text-lg font-semibold text-gray-900">
          เลือกเหตุผลการยกเลิก
        </h3>
        <p class="mt-1 text-sm text-gray-600">
          โปรดเลือกเหตุผลตามตัวเลือกที่กำหนด
        </p>

        <div class="mt-4">
          <label class="block mb-1 text-sm text-gray-700">เหตุผล</label>
          <select
            v-model="selectedCancelReason"
            class="w-full px-3 py-2 border border-gray-300 rounded-md"
          >
            <option value="" disabled>-- เลือกเหตุผล --</option>
            <option
              v-for="r in cancelReasonOptions"
              :key="r.value"
              :value="r.value"
            >
              {{ r.label }}
            </option>
          </select>
          <p v-if="cancelReasonError" class="mt-2 text-sm text-red-600">
            {{ cancelReasonError }}
          </p>
        </div>

        <div class="flex justify-end gap-2 mt-6">
          <button
            @click="closeCancelModal"
            class="px-4 py-2 text-sm text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
          >
            ปิด
          </button>
          <button
            @click="submitCancel"
            :disabled="!selectedCancelReason || isSubmittingCancel"
            class="px-4 py-2 text-sm text-white bg-red-600 rounded-md hover:bg-red-700 disabled:opacity-50"
          >
            {{ isSubmittingCancel ? "กำลังส่ง..." : "ยืนยันการยกเลิก" }}
          </button>
        </div>
      </div>
    </div>

    <!-- REPORT MODAL -->
    <div
      v-if="isReportModalOpen"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
      @click.self="closeReportModal"
    >
      <div class="w-full max-w-2xl p-6 bg-white rounded-lg shadow-xl">
        <h3 class="text-lg font-semibold text-gray-900">
          รายงานปัญหาการเดินทาง
        </h3>
        <p class="mt-1 text-sm text-gray-600">โปรดกรอกข้อมูลให้ครบถ้วน</p>

        <div class="mt-4 space-y-4">
          <!-- เลือกว่าจะรีพอร์ตใคร -->
          <div>
            <label class="block mb-2 text-sm text-gray-700">
              เลือกผู้ที่ต้องการรายงาน
            </label>

            <div class="overflow-y-auto border rounded-md max-h-48">
              <table class="w-full text-sm text-left">
                <thead class="bg-gray-100">
                  <tr>
                    <th class="px-3 py-2">เลือก</th>
                    <th class="px-3 py-2">ชื่อ</th>
                    <th class="px-3 py-2">บทบาท</th>
                  </tr>
                </thead>

                <tbody>
                  <tr
                    v-for="user in reportableUsers"
                    :key="user.id"
                    class="border-t"
                  >
                    <td class="px-3 py-2">
                      <input
                        type="checkbox"
                        :value="user.id"
                        v-model="reportForm.reportedUserIds"
                        :disabled="blockedReportedUserIds.includes(user.id)"
                      />
                    </td>

                    <td class="px-3 py-2">
                      {{ user.firstName }} {{ user.lastName }}

                      <span
                        v-if="blockedReportedUserIds.includes(user.id)"
                        class="block mt-1 text-xs text-red-500"
                      >
                        มีเคสที่กำลังตรวจสอบอยู่
                      </span>
                    </td>

                    <td class="px-3 py-2">
                      <span
                        class="px-2 py-1 text-xs rounded"
                        :class="
                          user.role === 'DRIVER'
                            ? 'bg-blue-100 text-blue-700'
                            : 'bg-green-100 text-green-700'
                        "
                      >
                        {{ user.role === "DRIVER" ? "คนขับ" : "ผู้โดยสาร" }}
                      </span>
                    </td>
                  </tr>

                  <tr v-if="reportableUsers.length === 0">
                    <td colspan="3" class="px-3 py-4 text-center text-gray-400">
                      ไม่พบผู้ที่สามารถรายงานได้
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Category -->
          <div>
            <label class="block mb-1 text-sm text-gray-700">
              ประเภทปัญหา
            </label>
            <select
              v-model="reportForm.category"
              class="w-full px-3 py-2 border border-gray-300 rounded-md"
            >
              <option disabled value="">-- เลือกประเภท --</option>

              <option value="DANGEROUS_DRIVING">ขับรถอันตราย</option>
              <option value="AGGRESSIVE_BEHAVIOR">พฤติกรรมก้าวร้าว</option>
              <option value="HARASSMENT">คุกคาม</option>
              <option value="NO_SHOW">ไม่มาตามนัด</option>
              <option value="FRAUD_OR_SCAM">โกง / หลอกลวง</option>
              <option value="OTHER">อื่น ๆ</option>
            </select>
          </div>
          <!-- Description -->
          <div>
            <label class="block mb-1 text-sm text-gray-700">รายละเอียด</label>
            <textarea
              v-model="reportForm.description"
              rows="4"
              class="w-full px-3 py-2 border border-gray-300 rounded-md"
              placeholder="กรอกรายละเอียดปัญหา..."
            ></textarea>
          </div>

          <!-- Evidence -->
          <div>
            <label class="block mb-1 text-sm text-gray-700">
              แนบหลักฐาน (รูปภาพและวิดีโอ แต่ละชนิดไม่เกิน 3 ไฟล์)
            </label>
            <input
              type="file"
              multiple
              accept="image/*,video/*"
              @change="handleEvidenceUpload"
              class="w-full text-sm"
            />
            <p class="mt-1 text-xs text-gray-500">
              รองรับ: รูปภาพและวิดีโอ (แต่ละชนิดไม่เกิน 3 ไฟล์, ขนาดไม่เกิน
              10MB/ไฟล์)
            </p>

            <!-- Preview ไฟล์ที่เลือก -->
            <div
              v-if="reportForm.evidences.length > 0"
              class="grid grid-cols-2 gap-3 mt-3 md:grid-cols-3"
            >
              <div
                v-for="(evidence, index) in reportForm.evidences"
                :key="index"
                class="relative"
              >
                <img
                  v-if="evidence.type === 'IMAGE'"
                  :src="evidence.previewUrl"
                  class="object-cover w-full border border-gray-300 rounded-lg aspect-video"
                />
                <video
                  v-else-if="evidence.type === 'VIDEO'"
                  :src="evidence.previewUrl"
                  class="object-cover w-full border border-gray-300 rounded-lg aspect-video"
                  controls
                ></video>
                <button
                  @click="removeEvidence(index)"
                  class="absolute top-1 right-1 px-2 py-1 text-xs text-white bg-red-500 rounded-full hover:bg-red-600"
                >
                  ✕
                </button>
                <p class="mt-1 text-xs text-gray-600 truncate">
                  {{ evidence.fileName }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <div class="flex justify-end gap-2 mt-6">
          <button
            @click="closeReportModal"
            class="px-4 py-2 text-sm text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
          >
            ปิด
          </button>

          <button
            @click="submitReport"
            :disabled="isSubmittingReport"
            class="px-4 py-2 text-sm text-white bg-yellow-600 rounded-md hover:bg-yellow-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isSubmittingReport ? "กำลังส่ง..." : "ส่งรายงาน" }}
          </button>
        </div>
      </div>
    </div>

    <ConfirmModal
      :show="isModalVisible"
      :title="modalContent.title"
      :message="modalContent.message"
      :confirmText="modalContent.confirmText"
      :variant="modalContent.variant"
      @confirm="handleConfirmAction"
      @cancel="closeConfirmModal"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick, onActivated } from "vue";
import dayjs from "dayjs";
import "dayjs/locale/th";
import buddhistEra from "dayjs/plugin/buddhistEra";
import ConfirmModal from "~/components/ConfirmModal.vue";
import { useToast } from "~/composables/useToast";
import { useRouter, useRoute } from "vue-router";

const router = useRouter();
const route = useRoute();

const tokenCookie = useCookie("token");
const userCookie = useCookie("user");

// State สำหรับการรีวิว
const showReviewModal = ref(false);
const reviewTrip = ref(null);
const isSubmittingReview = ref(false);

const rating = ref(5);
const comment = ref("");
const reviewImages = ref([]);
const reviewedBookings = ref({});
const driverReviews = ref({});

//
function getDriverRating(driverId) {
  const reviews = driverReviews.value[driverId] || [];

  if (!reviews.length) {
    return { avg: 0, count: 0 };
  }

  const total = reviews.reduce((sum, r) => sum + r.rating, 0);
  const avg = (total / reviews.length).toFixed(1);

  return {
    avg,
    count: reviews.length,
  };
}

// เปิด modal รีวิว
function openReviewModal(trip) {
  reviewTrip.value = trip;
  rating.value = 5;
  comment.value = "";
  reviewImages.value = [];
  showReviewModal.value = true;
}

// ดึงรีวิวของคนขับมาแสดง
async function fetchDriverReviews(driverId) {
  try {
    const res = await $api(`/reviews/driver/${driverId}`);

    driverReviews.value = {
      ...driverReviews.value,
      [driverId]: res.data || [],
    };

  } catch (err) {
    console.error("โหลดรีวิวคนขับไม่สำเร็จ", err);
    driverReviews.value = {
      ...driverReviews.value,
      [driverId]: [],
    };
  }
}

// เช็คว่ารีวิวแล้วหรือยัง
async function checkReviewStatus(bookingId) {
  try {
    const res = await $api(`/reviews/booking/${bookingId}`)
    reviewedBookings.value = {
      ...reviewedBookings.value,
      [bookingId]: !!(res?.id || (Array.isArray(res) && res.length > 0)),
    }
  } catch (err) {
    reviewedBookings.value = {
      ...reviewedBookings.value,
      [bookingId]: false,
    }
  }
}

// ส่งรีวิว
async function submitReview() {
  if (isSubmittingReview.value) return;

  try {
    if (!rating.value) {
      alert("กรุณาให้คะแนน");
      return;
    }

    isSubmittingReview.value = true;

    const imageUrls = await Promise.all(
      reviewImages.value.map(async (img) => {
        const data = await uploadToCloudinary(img.file);
        return data.secure_url;
      }),
    );

    let finalComment = comment.value || "";

    if (imageUrls.length > 0) {
      finalComment += "\n\n[images]\n" + imageUrls.join("\n") + "\n[/images]";
    }

    await $api("/reviews", {
      method: "POST",
      body: {
        bookingId: reviewTrip.value.id,
        rating: rating.value,
        comment: finalComment,
      },
    });

    toast.success("รีวิวสำเร็จ");

    // เปลี่ยนปุ่มเป็น "รีวิวแล้ว"
    reviewedBookings.value[reviewTrip.value.id] = true;

    // บันทึก driverId ก่อนที่ reviewTrip จะถูก reset
    const reviewedDriverId = reviewTrip.value.driverId;

    await fetchDriverReviews(reviewedDriverId);

    showReviewModal.value = false;

    // reset form
    comment.value = "";
    rating.value = 5;
    reviewImages.value = [];

    // โหลด trips ใหม่
    await fetchMyTrips();
    // โหลดรีวิวของคนขับใหม่ (ใช้ driverId ที่บันทึกไว้)
    await fetchDriverReviews(reviewedDriverId);

    // ตรวจสอบว่า booking ไหนรีวิวแล้ว
    for (const trip of allTrips.value) {
      if (trip.status === "completed") {
        await checkReviewStatus(trip.id);
      }
    }
  } catch (err) {
    alert(err?.data?.message || "ไม่สามารถรีวิวได้");
  } finally {
    isSubmittingReview.value = false;
  }
}

// จัดการอัปโหลดรูป
function handleReviewImages(e) {
  const files = Array.from(e.target.files);

  if (reviewImages.value.length + files.length > 3) {
    alert("อัปโหลดได้ไม่เกิน 3 รูป");
    e.target.value = "";
    return;
  }

  const newImages = files.map((file) => ({
    file,
    preview: URL.createObjectURL(file),
  }));

  reviewImages.value.push(...newImages);

  // reset input
  e.target.value = "";
}

// ลบรูปก่อน submit
function removeReviewImage(index) {
  reviewImages.value.splice(index, 1);
}

// ใช้ computed เพื่อให้ดึงค่าได้อย่างถูกต้องและปลอดภัยใน Nuxt
const myUserId = computed(() => {
  if (userCookie.value) {
    try {
      const userData =
        typeof userCookie.value === "string"
          ? JSON.parse(decodeURIComponent(userCookie.value))
          : userCookie.value;

      if (userData?.id) return String(userData.id);
    } catch (err) {
      console.error("Parse userCookie error:", err);
    }
  }

  if (tokenCookie.value) {
    try {
      const payload = JSON.parse(atob(tokenCookie.value.split(".")[1]));
      if (payload?.sub) return String(payload.sub);
    } catch (err) {
      console.error("Parse tokenCookie error:", err);
    }
  }

  if (typeof window !== "undefined") {
    const localToken = localStorage.getItem("token");
    if (localToken) {
      try {
        const payload = JSON.parse(atob(localToken.split(".")[1]));
        if (payload?.sub) return String(payload.sub);
      } catch (err) {}
    }
  }

  return null;
});

const isSubmittingReport = ref(false);
const isReportModalOpen = ref(false);
const selectedReportTrip = ref(null);

const reportableUsers = computed(() => {
  if (!selectedReportTrip.value) return [];

  const trip = selectedReportTrip.value;
  const users = [];
  const currentUserId = myUserId.value; // ดึงค่าจาก computed ด้านบน

  // เพิ่มคนขับ
  if (trip.driverId && String(trip.driverId) !== currentUserId) {
    users.push({
      id: trip.driverId,
      firstName:
        trip.driver?.name?.split(" ")[0] ||
        trip.driver?.firstName ||
        "ไม่ทราบชื่อ",
      lastName:
        trip.driver?.name?.split(" ").slice(1).join(" ") ||
        trip.driver?.lastName ||
        "",
      role: "DRIVER",
    });
  }

  // เพิ่มผู้โดยสาร
  if (Array.isArray(trip.passengers)) {
    trip.passengers.forEach((p) => {
      // ถ้าไม่มี ID หรือ ID ตรงกับตัวเอง ให้ข้ามไป
      if (!p?.id || String(p.id) === currentUserId) return;

      users.push({
        id: p.id,
        firstName: p.firstName || "ไม่ทราบชื่อ",
        lastName: p.lastName || "",
        role: "PASSENGER",
      });
    });
  }

  // ป้องกันการแสดงชื่อคนซ้ำ
  const seen = new Set();
  return users.filter((u) => {
    if (seen.has(u.id)) return false;
    seen.add(u.id);
    return true;
  });
});

const blockedReportedUserIds = computed(() => {
  if (!selectedReportTrip.value?.reportCases) return [];

  return selectedReportTrip.value.reportCases
    .filter((r) =>
      ["FILED", "UNDER_REVIEW", "INVESTIGATING"].includes(r.status),
    )
    .map((r) => r.driverId);
});

// เช็คว่า trip นี้มีการรายงานที่ยังไม่ได้ปิดหรือยัง
const hasActiveReport = (trip) => {
  if (!trip?.reportCases || trip.reportCases.length === 0) return false;

  return trip.reportCases.some((r) =>
    ["FILED", "UNDER_REVIEW", "INVESTIGATING", "RESOLVED"].includes(r.status),
  );
};

const reportForm = ref({
  bookingId: null,
  routeId: null,
  reportedUserIds: [],
  category: "",
  description: "",
  evidences: [],
});

function openReportModal(trip) {
  selectedReportTrip.value = trip;

  reportForm.value = {
    bookingId: trip.id,
    routeId: trip.routeId,
    reportedUserIds: [],
    category: "",
    description: "",
    evidences: [],
  };

  isReportModalOpen.value = true;
}

function closeReportModal() {
  isReportModalOpen.value = false;
  selectedReportTrip.value = null;

  reportForm.value = {
    bookingId: null,
    routeId: null,
    reportedUserIds: [],
    category: "",
    description: "",
    evidences: [],
  };
}

async function uploadToCloudinary(file) {
  const config = useRuntimeConfig();
  const formData = new FormData();
  formData.append("file", file);
  formData.append("upload_preset", config.public.cloudinaryUploadPreset);

  // ใช้ endpoint ที่เหมาะสมตามประเภทไฟล์
  const resourceType = file.type.startsWith("video") ? "video" : "image";

  const response = await fetch(
    `https://api.cloudinary.com/v1_1/${config.public.cloudinaryCloudName}/${resourceType}/upload`,
    {
      method: "POST",
      body: formData,
    },
  );

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    console.error("Cloudinary error:", errorData);
    throw new Error(errorData.error?.message || "อัปโหลดไฟล์ไม่สำเร็จ");
  }

  return response.json();
}

async function submitReport() {
  if (isSubmittingReport.value) return;

  try {
    // console.log('[submitReport] reportForm:', JSON.parse(JSON.stringify(reportForm.value)));

    if (!reportForm.value.reportedUserIds.length) {
      // console.log('[submitReport] ไม่ได้เลือกผู้ที่ต้องการรายงาน');
      toast.error("กรุณาเลือกผู้ที่ต้องการรายงาน");
      return;
    }

    if (!reportForm.value.category) {
      // console.log('[submitReport] ไม่ได้เลือกประเภทปัญหา');
      toast.error("กรุณาเลือกประเภทปัญหา");
      return;
    }

    if (
      !reportForm.value.description ||
      reportForm.value.description.trim().length < 10
    ) {
      // console.log('[submitReport] รายละเอียดไม่ครบ 10 ตัวอักษร');
      toast.error("รายละเอียดต้องมีอย่างน้อย 10 ตัวอักษร");
      return;
    }

    const hasBlockedUser = reportForm.value.reportedUserIds.some((id) =>
      blockedReportedUserIds.value.includes(id),
    );

    if (hasBlockedUser) {
      // console.log('[submitReport] มีผู้ใช้ที่ถูก block อยู่:', blockedReportedUserIds.value);
      toast.error("ไม่สามารถรายงานซ้ำได้ กรุณารอให้การตรวจสอบเสร็จสิ้น");
      return;
    }

    // console.log('[submitReport] ผ่านการ validate ทั้งหมด');
    isSubmittingReport.value = true;

    // อัปโหลดไฟล์ไปที่ Cloudinary ก่อน
    const evidences = [];
    if (reportForm.value.evidences.length > 0) {
      // console.log('[submitReport] เริ่มอัปโหลดไฟล์', reportForm.value.evidences.length, 'ไฟล์');
      toast.info("กำลังอัปโหลดไฟล์...");

      for (const evidence of reportForm.value.evidences) {
        try {
          // console.log('[submitReport] อัปโหลด:', evidence.fileName);
          const cloudinaryData = await uploadToCloudinary(evidence.file);
          // console.log('[submitReport] อัปโหลดสำเร็จ:', cloudinaryData.secure_url);
          evidences.push({
            type: evidence.type,
            url: cloudinaryData.secure_url,
            fileName: evidence.fileName,
            mimeType: evidence.mimeType,
            fileSize: evidence.fileSize,
          });
        } catch (err) {
          console.error("[submitReport] Error uploading file:", err);
          toast.error(`ไม่สามารถอัปโหลดไฟล์ ${evidence.fileName}`);
          throw err;
        }
      }
      // console.log('[submitReport] อัปโหลดไฟล์สำเร็จทั้งหมด:', evidences);
    }

    // ส่งรายงานพร้อม URL ของไฟล์
    const reportPayload = {
      bookingId: reportForm.value.bookingId || null,
      routeId: reportForm.value.routeId || null,
      reportedUserIds: reportForm.value.reportedUserIds,
      category: reportForm.value.category,
      description: reportForm.value.description.trim(),
    };
    // console.log('[submitReport] ส่ง report payload:', reportPayload);

    const response = await $api("/reports", {
      method: "POST",
      body: reportPayload,
    });

    // console.log('[submitReport] Response จากการสร้าง report:', response);

    // รองรับทั้งกรณี response เป็น Array หรือ Object
    const reportData = Array.isArray(response) ? response[0] : response;
    // console.log('[submitReport] reportData:', reportData);

    // ถ้ามี groupId ใช้ groupId, ไม่มีใช้ id
    const reportId = reportData?.groupId || reportData?.id;
    // console.log('[submitReport] reportId (groupId || id):', reportId);

    // อัปโหลดหลักฐาน (ถ้ามี)
    if (evidences.length > 0 && reportId) {
      // console.log('[submitReport] เริ่มส่งหลักฐาน');
      try {
        // console.log('[submitReport] reportId ที่จะใช้:', reportId);

        const evidencePayload = { evidences };
        // console.log('[submitReport] evidence payload:', evidencePayload);
        // console.log('[submitReport] endpoint:', `/reports/${reportId}/evidence`);

        const evidenceResponse = await $api(`/reports/${reportId}/evidence`, {
          method: "POST",
          body: evidencePayload,
        });
        // console.log('[submitReport] Response จากการส่งหลักฐาน:', evidenceResponse);
      } catch (err) {
        console.error("[submitReport]  Error uploading evidences:", err);
        console.error("[submitReport] Error details:", err.data || err.message);
        // ไม่ throw error เพราะรายงานส่งไปแล้ว
      }
    } else if (evidences.length > 0 && !reportId) {
      // console.log('[submitReport] ไม่พบ reportId - ไม่สามารถส่งหลักฐานได้');
    }

    // console.log('[submitReport] สำเร็จ! กำลังปิด modal และ refresh');
    toast.success(
      "ส่งรายงานสำเร็จ\n\nหากต้องการเพิ่มหลักฐานเพิ่มเติม\nสามารถไปที่หน้าประวัติการรายงานได้",
      { duration: 5000 },
    );

    closeReportModal();

    // รีเฟรชข้อมูลเพื่ออัพเดทสถานะว่ารายงานแล้ว
    await fetchMyTrips();

    // นำทางไปหน้าประวัติ
    setTimeout(() => {
      // console.log('[submitReport] Navigate to /myHistory');
      router.push("/myHistory");
    }, 1500);
  } catch (error) {
    console.error("[submitReport] Error:", error);
    console.error("[submitReport] Error data:", error?.data);
    console.error("[submitReport] Error message:", error?.message);
    const errorMessage =
      error?.data?.message || error?.message || "ไม่สามารถส่งรายงานได้";
    toast.error(errorMessage);
  } finally {
    isSubmittingReport.value = false;
    // console.log('[submitReport] จบฟังก์ชัน submitReport');
  }
}

function handleEvidenceUpload(event) {
  const files = Array.from(event.target.files);
  const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

  // ตรวจสอบขนาดไฟล์
  for (const file of files) {
    if (file.size > MAX_FILE_SIZE) {
      toast.error(`ไฟล์ ${file.name} มีขนาดใหญ่เกิน 10MB`);
      event.target.value = ""; // รีเซ็ต input
      return;
    }
  }

  const newEvidences = files.map((file) => {
    const type = file.type.startsWith("image")
      ? "IMAGE"
      : file.type.startsWith("video")
        ? "VIDEO"
        : "FILE";

    return {
      type,
      file,
      previewUrl: URL.createObjectURL(file),
      fileName: file.name,
      mimeType: file.type,
      fileSize: file.size,
    };
  });

  // ตรวจสอบจำนวนแต่ละประเภท
  const allEvidences = [...reportForm.value.evidences, ...newEvidences];
  const imageCount = allEvidences.filter((e) => e.type === "IMAGE").length;
  const videoCount = allEvidences.filter((e) => e.type === "VIDEO").length;

  if (imageCount > 3) {
    toast.error("รูปภาพไม่เกิน 3 ไฟล์");
    event.target.value = "";
    return;
  }

  if (videoCount > 3) {
    toast.error("วิดีโอไม่เกิน 3 ไฟล์");
    event.target.value = "";
    return;
  }

  reportForm.value.evidences = allEvidences;
  event.target.value = ""; // รีเซ็ตเพื่อให้เลือกไฟล์เดิมได้อีก
}

function removeEvidence(index) {
  reportForm.value.evidences.splice(index, 1);
}

// Setup dayjs for Thai locale
dayjs.locale("th");
dayjs.extend(buddhistEra);

const { $api } = useNuxtApp();
const { toast } = useToast();

// --- State Management ---
const activeTab = ref("pending");
const selectedTripId = ref(null);
const isLoading = ref(false);
const mapContainer = ref(null);
let map = null;
let currentPolyline = null;
let currentMarkers = [];
const allTrips = ref([]);

let gmap = null; // Google Map instance
let activePolyline = null;
let startMarker = null;
let endMarker = null;
let geocoder = null;
let placesService = null;
const mapReady = ref(false);
let stopMarkers = [];

const GMAPS_CB = "__gmapsReady__";

const tabs = [
  { status: "pending", label: "รอดำเนินการ" },
  { status: "confirmed", label: "ยืนยันแล้ว" },
  { status: "completed", label: "เสร็จสิ้น" },
  { status: "rejected", label: "ปฏิเสธ" },
  { status: "cancelled", label: "ยกเลิก" },
  { status: "all", label: "ทั้งหมด" },
];

definePageMeta({ middleware: "auth" });

const cancelReasonOptions = [
  { value: "CHANGE_OF_PLAN", label: "เปลี่ยนแผน/มีธุระกะทันหัน" },
  { value: "FOUND_ALTERNATIVE", label: "พบวิธีเดินทางอื่นแล้ว" },
  { value: "DRIVER_DELAY", label: "คนขับล่าช้าหรือเลื่อนเวลา" },
  { value: "PRICE_ISSUE", label: "ราคาหรือค่าใช้จ่ายไม่เหมาะสม" },
  { value: "WRONG_LOCATION", label: "เลือกจุดรับ–ส่งผิด" },
  { value: "DUPLICATE_OR_WRONG_DATE", label: "จองซ้ำหรือจองผิดวัน" },
  { value: "SAFETY_CONCERN", label: "กังวลด้านความปลอดภัย" },
  { value: "WEATHER_OR_FORCE_MAJEURE", label: "สภาพอากาศ/เหตุสุดวิสัย" },
  { value: "COMMUNICATION_ISSUE", label: "สื่อสารไม่สะดวก/ติดต่อไม่ได้" },
];

const isCancelModalVisible = ref(false);
const isSubmittingCancel = ref(false);
const selectedCancelReason = ref("");
const cancelReasonError = ref("");
const tripToCancel = ref(null);

// --- Computed Properties ---
const filteredTrips = computed(() => {
  if (activeTab.value === "all") return allTrips.value;
  return allTrips.value.filter((trip) => trip.status === activeTab.value);
});

const selectedTrip = computed(() => {
  return (
    allTrips.value.find((trip) => trip.id === selectedTripId.value) || null
  );
});

function cleanAddr(a) {
  return (a || "")
    .replace(/,?\s*(Thailand|ไทย|ประเทศ)\s*$/i, "")
    .replace(/\s{2,}/g, " ")
    .trim();
}

// --- Methods ---
async function fetchMyTrips() {
  isLoading.value = true;
  try {
    const bookings = await $api("/bookings/me");

    // map ข้อมูลพื้นฐานก่อน (ตั้งชื่อชั่วคราวเป็นพิกัด แล้วไป reverse geocode ภายหลัง)
    const formatted = bookings.map((b) => {
      const driverData = {
        id: b.route.driver.id, // เพิ่มบรรทัดนี้
        name: `${b.route.driver.firstName} ${b.route.driver.lastName}`.trim(),
        image:
          b.route.driver.profilePicture ||
          `https://ui-avatars.com/api/?name=${encodeURIComponent(b.route.driver.firstName || "U")}&background=random&size=64`,
        rating: 4.5,
        reviews: Math.floor(Math.random() * 50) + 5,
      };

      const carDetails = [];
      if (b.route.vehicle) {
        carDetails.push(
          `${b.route.vehicle.vehicleModel} (${b.route.vehicle.vehicleType})`,
        );
        if (
          Array.isArray(b.route.vehicle.amenities) &&
          b.route.vehicle.amenities.length
        ) {
          carDetails.push(...b.route.vehicle.amenities);
        }
      } else {
        carDetails.push("ไม่มีข้อมูลรถ");
      }

      const start = b.route.startLocation;
      const end = b.route.endLocation;

      const wp = b.route.waypoints || {};
      const baseList =
        (Array.isArray(wp.used) && wp.used.length
          ? wp.used
          : Array.isArray(wp.requested)
            ? wp.requested
            : []) || [];
      const orderedList =
        Array.isArray(wp.optimizedOrder) &&
        wp.optimizedOrder.length === baseList.length
          ? wp.optimizedOrder.map((i) => baseList[i])
          : baseList;

      const stops = orderedList
        .map((p) => {
          const name = p?.name || "";
          const address = cleanAddr(p?.address || "");
          const fallback =
            p?.lat != null && p?.lng != null
              ? `(${Number(p.lat).toFixed(6)}, ${Number(p.lng).toFixed(6)})`
              : "";
          const title = name || fallback;
          return address ? `${title} — ${address}` : title;
        })
        .filter(Boolean);

      const stopsCoords = orderedList
        .map((p) =>
          p && typeof p.lat === "number" && typeof p.lng === "number"
            ? {
                lat: Number(p.lat),
                lng: Number(p.lng),
                name: p.name || "",
                address: p.address || "",
              }
            : null,
        )
        .filter(Boolean);

      return {
        id: b.id,
        bookingId: b.id,
        routeId: b.route.id,
        driverId: driverData.id,
        reportCases: b.reportCases || [],

        status:
          b.route?.status === "COMPLETED"
            ? "completed"
            : String(b.status || "").toLowerCase(),
        origin:
          start?.name ||
          `(${Number(start.lat).toFixed(2)}, ${Number(start.lng).toFixed(2)})`,
        destination:
          end?.name ||
          `(${Number(end.lat).toFixed(2)}, ${Number(end.lng).toFixed(2)})`,
        originAddress: start?.address ? cleanAddr(start.address) : null,
        destinationAddress: end?.address ? cleanAddr(end.address) : null,
        originHasName: !!start?.name,
        destinationHasName: !!end?.name,
        pickupPoint: b.pickupLocation?.name || "-",
        date: dayjs(b.route.departureTime).format("D MMMM BBBB"),
        time: dayjs(b.route.departureTime).format("HH:mm น."),
        price: (b.route.pricePerSeat || 0) * (b.numberOfSeats || 1),
        seats: b.numberOfSeats || 1,
        driver: driverData,

        passengers: Array.isArray(b.route.bookings)
          ? b.route.bookings
              .map((bk) => {
                if (!bk.passenger) return null; // กันกรณีไม่มี include passenger
                return {
                  id: bk.passenger.id,
                  firstName: bk.passenger.firstName || "",
                  lastName: bk.passenger.lastName || "",
                  name: `${bk.passenger.firstName || ""} ${bk.passenger.lastName || ""}`.trim(),
                };
              })
              .filter(Boolean)
          : [],

        coords: [
          [start.lat, start.lng],
          [end.lat, end.lng],
        ],
        polyline: b.route.routePolyline || null, // ใช้เมื่อมี
        stops,
        stopsCoords,
        carDetails,
        conditions: b.route.conditions,
        photos: b.route.vehicle?.photos || [],
        durationText:
          (typeof b.route.duration === "string"
            ? formatDuration(b.route.duration)
            : b.route.duration) ||
          (typeof b.route.durationSeconds === "number"
            ? `${Math.round(b.route.durationSeconds / 60)} นาที`
            : "-"),
        distanceText:
          (typeof b.route.distance === "string"
            ? formatDistance(b.route.distance)
            : b.route.distance) ||
          (typeof b.route.distanceMeters === "number"
            ? `${(b.route.distanceMeters / 1000).toFixed(1)} กม.`
            : "-"),
      };
    });

    allTrips.value = formatted;

    for (const trip of formatted) {
      await checkReviewStatus(trip.id);
    }

    // รอให้แผนที่พร้อมก่อน แล้วค่อย reverse geocode เพื่อได้ "ชื่อสถานที่" สวยๆ
    await waitMapReady();

    const jobs = allTrips.value.map(async (t, idx) => {
      const [o, d] = await Promise.all([
        reverseGeocode(t.coords[0][0], t.coords[0][1]),
        reverseGeocode(t.coords[1][0], t.coords[1][1]),
      ]);
      const oParts = await extractNameParts(o);
      const dParts = await extractNameParts(d);

      if (!allTrips.value[idx].originHasName && oParts.name) {
        allTrips.value[idx].origin = oParts.name;
      }
      if (!allTrips.value[idx].destinationHasName && dParts.name) {
        allTrips.value[idx].destination = dParts.name;
      }
    });

    await Promise.allSettled(jobs);
  } catch (error) {
    console.error("Failed to fetch my trips:", error);
    allTrips.value = [];
  } finally {
    isLoading.value = false;
  }
}

function waitMapReady() {
  return new Promise((resolve) => {
    if (mapReady.value) return resolve(true);
    const t = setInterval(() => {
      if (mapReady.value) {
        clearInterval(t);
        resolve(true);
      }
    }, 50);
  });
}

function reverseGeocode(lat, lng) {
  return new Promise((resolve) => {
    if (!geocoder) return resolve(null);
    geocoder.geocode({ location: { lat, lng } }, (results, status) => {
      if (status !== "OK" || !results?.length) return resolve(null);
      resolve(results[0]);
    });
  });
}

async function extractNameParts(geocodeResult) {
  if (!geocodeResult) return { name: null, area: null };

  const comps = geocodeResult.address_components || [];
  const byType = (t) => comps.find((c) => c.types.includes(t))?.long_name;
  const byTypeShort = (t) => comps.find((c) => c.types.includes(t))?.short_name;

  const types = geocodeResult.types || [];
  const isPoi =
    types.includes("point_of_interest") ||
    types.includes("establishment") ||
    types.includes("premise");

  let name = null;
  if (isPoi && geocodeResult.place_id) {
    const poiName = await getPlaceName(geocodeResult.place_id);
    if (poiName) name = poiName;
  }
  if (!name) {
    const streetNumber = byType("street_number");
    const route = byType("route");
    name =
      streetNumber && route
        ? `${streetNumber} ${route}`
        : route || geocodeResult.formatted_address || null;
  }

  const sublocality =
    byType("sublocality") ||
    byType("neighborhood") ||
    byType("locality") ||
    byType("administrative_area_level_2");
  const province =
    byType("administrative_area_level_1") ||
    byTypeShort("administrative_area_level_1");

  let area = null;
  if (sublocality && province) area = `${sublocality}, ${province}`;
  else if (province) area = province;

  if (name) name = name.replace(/,?\s*(Thailand|ไทย)\s*$/i, "");
  return { name, area };
}

function getPlaceName(placeId) {
  return new Promise((resolve) => {
    if (!placesService || !placeId) return resolve(null);
    placesService.getDetails({ placeId, fields: ["name"] }, (place, status) => {
      if (status === google.maps.places.PlacesServiceStatus.OK && place?.name)
        resolve(place.name);
      else resolve(null);
    });
  });
}

const getTripCount = (status) => {
  if (status === "all") return allTrips.value.length;
  return allTrips.value.filter((trip) => trip.status === status).length;
};

const toggleTripDetails = async (tripId) => {
  const trip = allTrips.value.find((t) => t.id === tripId);

  if (trip) {
    await fetchDriverReviews(trip.driverId);
    updateMap(trip);
  }

  if (selectedTripId.value === tripId) {
    selectedTripId.value = null;
  } else {
    selectedTripId.value = tripId;
  }
};
async function updateMap(trip) {
  if (!trip) return;
  await waitMapReady();
  if (!gmap) return;

  // cleanup ของเดิม
  if (activePolyline) {
    activePolyline.setMap(null);
    activePolyline = null;
  }
  if (startMarker) {
    startMarker.setMap(null);
    startMarker = null;
  }
  if (endMarker) {
    endMarker.setMap(null);
    endMarker = null;
  }
  if (stopMarkers.length) {
    stopMarkers.forEach((m) => m.setMap(null));
    stopMarkers = [];
  }

  const start = {
    lat: Number(trip.coords[0][0]),
    lng: Number(trip.coords[0][1]),
  };
  const end = {
    lat: Number(trip.coords[1][0]),
    lng: Number(trip.coords[1][1]),
  };

  // หมุด A/B
  startMarker = new google.maps.Marker({
    position: start,
    map: gmap,
    label: "A",
  });
  endMarker = new google.maps.Marker({ position: end, map: gmap, label: "B" });

  if (Array.isArray(trip.stopsCoords) && trip.stopsCoords.length) {
    stopMarkers = trip.stopsCoords.map(
      (s, idx) =>
        new google.maps.Marker({
          position: { lat: s.lat, lng: s.lng },
          map: gmap,
          icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png",
          title: s.name || s.address || `จุดแวะ ${idx + 1}`,
        }),
    );
  }

  // เส้นทางจาก polyline ถ้ามี
  if (trip.polyline && google.maps.geometry?.encoding) {
    const path = google.maps.geometry.encoding.decodePath(trip.polyline);
    activePolyline = new google.maps.Polyline({
      path,
      map: gmap,
      strokeColor: "#2563eb",
      strokeOpacity: 0.9,
      strokeWeight: 5,
    });
    const bounds = new google.maps.LatLngBounds();
    path.forEach((p) => bounds.extend(p));

    if (trip.stopsCoords?.length) {
      trip.stopsCoords.forEach((s) =>
        bounds.extend(new google.maps.LatLng(s.lat, s.lng)),
      );
    }

    gmap.fitBounds(bounds);
  } else {
    // ไม่มี polyline → fit จากจุด A-B + จุดแวะ
    const bounds = new google.maps.LatLngBounds();
    bounds.extend(start);
    bounds.extend(end);
    if (trip.stopsCoords?.length) {
      trip.stopsCoords.forEach((s) =>
        bounds.extend(new google.maps.LatLng(s.lat, s.lng)),
      );
    }
    gmap.fitBounds(bounds);
  }
}

// --- Modal Logic ---
const isModalVisible = ref(false);
const tripToAction = ref(null);
const modalContent = ref({
  title: "",
  message: "",
  confirmText: "",
  action: null,
  variant: "danger",
});

const openConfirmModal = (trip, action) => {
  tripToAction.value = trip;
  if (action === "cancel") {
    // ตอนนี้ไม่ใช้ทางยืนยันตรง ๆ แล้ว แต่คงโครงไว้เผื่ออนาคต
    modalContent.value = {
      title: "ยืนยันการยกเลิกการจอง",
      message: `คุณต้องการยกเลิกการเดินทางไปที่ "${trip.destination}" ใช่หรือไม่?`,
      confirmText: "ใช่, ยกเลิกการจอง",
      action: "cancel",
      variant: "danger",
    };
  } else if (action === "delete") {
    modalContent.value = {
      title: "ยืนยันการลบรายการ",
      message: `คุณต้องการลบรายการเดินทางไปที่ "${trip.destination}" ออกจากประวัติใช่หรือไม่?`,
      confirmText: "ใช่, ลบรายการ",
      action: "delete",
      variant: "danger",
    };
  }
  isModalVisible.value = true;
};

const closeConfirmModal = () => {
  isModalVisible.value = false;
  tripToAction.value = null;
};

const handleConfirmAction = async () => {
  if (!tripToAction.value) return;
  const action = modalContent.value.action;
  const tripId = tripToAction.value.id;
  try {
    if (action === "cancel") {
      // ไม่ยิง PATCH ตรง ๆ — ต้องให้ผู้ใช้เลือกเหตุผลก่อน
      openCancelModal(tripToAction.value);
      closeConfirmModal();
      return;
    } else if (action === "delete") {
      await $api(`/bookings/${tripId}`, { method: "DELETE" });
      toast.success("ลบรายการสำเร็จ", "รายการได้ถูกลบออกจากประวัติแล้ว");
    }
    closeConfirmModal();
    await fetchMyTrips();
  } catch (error) {
    console.error(`Failed to ${action} booking:`, error);
    toast.error(
      "เกิดข้อผิดพลาด",
      error.data?.message || "ไม่สามารถดำเนินการได้",
    );
    closeConfirmModal();
  }
};

function openCancelModal(trip) {
  tripToCancel.value = trip;
  selectedCancelReason.value = "";
  cancelReasonError.value = "";
  isCancelModalVisible.value = true;
}

function closeCancelModal() {
  isCancelModalVisible.value = false;
  tripToCancel.value = null;
}

async function submitCancel() {
  if (!selectedCancelReason.value) {
    cancelReasonError.value = "กรุณาเลือกเหตุผล";
    return;
  }
  if (!tripToCancel.value) return;

  isSubmittingCancel.value = true;
  try {
    await $api(`/bookings/${tripToCancel.value.id}/cancel`, {
      method: "PATCH",
      body: { reason: selectedCancelReason.value }, // ✅ ตรงกับ schema ฝั่ง backend
    });
    toast.success("ยกเลิกการจองสำเร็จ", "ระบบบันทึกเหตุผลแล้ว");
    closeCancelModal();
    await fetchMyTrips();
  } catch (err) {
    console.error("Cancel booking failed:", err);
    toast.error("เกิดข้อผิดพลาด", err?.data?.message || "ไม่สามารถยกเลิกได้");
  } finally {
    isSubmittingCancel.value = false;
  }
}

function formatDistance(input) {
  if (typeof input !== "string") return input;
  const parts = input.split("+");
  if (parts.length <= 1) return input;

  let meters = 0;
  for (const seg of parts) {
    const n = parseFloat(seg.replace(/[^\d.]/g, ""));
    if (Number.isNaN(n)) continue;
    if (/กม/.test(seg)) meters += n * 1000;
    else if (/เมตร|ม\./.test(seg)) meters += n;
    else meters += n; // สมมติเป็นเมตรถ้าไม่พบหน่วย
  }

  if (meters >= 1000) {
    const km = Math.round((meters / 1000) * 10) / 10; // ปัดทศนิยม 1 ตำแหน่ง
    return `${km % 1 === 0 ? km.toFixed(0) : km} กม.`;
  }
  return `${Math.round(meters)} ม.`;
}

function formatDuration(input) {
  if (typeof input !== "string") return input;
  const parts = input.split("+");
  if (parts.length <= 1) return input;

  let minutes = 0;
  for (const seg of parts) {
    const n = parseFloat(seg.replace(/[^\d.]/g, ""));
    if (Number.isNaN(n)) continue;
    if (/ชม/.test(seg)) minutes += n * 60;
    else minutes += n; // นาที
  }

  const h = Math.floor(minutes / 60);
  const m = Math.round(minutes % 60);
  return h ? (m ? `${h} ชม. ${m} นาที` : `${h} ชม.`) : `${m} นาที`;
}

// --- Lifecycle and Watchers ---
useHead({
  title: "การเดินทางของฉัน - ไปนำแหน่",
  link: [
    {
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap",
    },
  ],
  script:
    process.client && !window.google?.maps
      ? [
          {
            key: "gmaps",
            src: `https://maps.googleapis.com/maps/api/js?key=${useRuntimeConfig().public.googleMapsApiKey}&libraries=places,geometry&callback=__gmapsReady__`,
            async: true,
            defer: true,
          },
        ]
      : [],
});

onMounted(() => {
  // ถ้า script โหลดแล้ว
  if (window.google?.maps) {
    initializeMap();
    // ถ้ามี query.refresh ให้ watch จัดการ ไม่ fetch ที่นี่
    if (!route.query.refresh) {
      fetchMyTrips().then(() => {
        if (filteredTrips.value.length) updateMap(filteredTrips.value[0]);
      });
    }
    return;
  }

  const token = localStorage.getItem("token") || tokenCookie.value;

  if (token) {
    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      myUserId.value = String(
        payload.sub || payload.id || payload.userId || "",
      );
    } catch (error) {
      console.error("Error parsing token:", error);
    }
  }

  if (!myUserId.value && userCookie.value) {
    try {
      // Nuxt มักจะแปลง JSON ใน Cookie ให้เป็น Object อัตโนมัติ แต่กันเหนียวไว้ก่อน
      const userData =
        typeof userCookie.value === "string"
          ? JSON.parse(decodeURIComponent(userCookie.value))
          : userCookie.value;

      if (userData?.id) {
        myUserId.value = String(userData.id);
      }
    } catch (err) {
      console.error("Error parsing user cookie:", err);
    }
  }

  // ยังไม่โหลดเสร็จ: ตั้ง callback
  window[GMAPS_CB] = () => {
    try {
      delete window[GMAPS_CB];
    } catch {}
    initializeMap();
    if (!route.query.refresh) {
      fetchMyTrips().then(() => {
        if (filteredTrips.value.length) updateMap(filteredTrips.value[0]);
      });
    }
  };
});

// Refresh ข้อมูลทุกครั้งที่เข้าหน้า (เมื่อ navigate กลับมา)
onActivated(() => {
  fetchMyTrips().then(() => {
    if (filteredTrips.value.length && selectedTripId.value) {
      const trip = allTrips.value.find((t) => t.id === selectedTripId.value);
      if (trip) updateMap(trip);
    } else if (filteredTrips.value.length) {
      updateMap(filteredTrips.value[0]);
    }
  });
});

// Watch query params เพื่อ refresh เมื่อมี query.refresh (จาก navigate หลังจอง)
watch(
  () => route.query.refresh,
  (newVal) => {
    if (newVal) {
      // console.log('[myTrip] Detected refresh query, fetching trips...');
      // Fetch ข้อมูลใหม่เมื่อมี refresh query
      fetchMyTrips().then(() => {
        // console.log('[myTrip] Fetched trips:', allTrips.value.length, 'trips');
        if (filteredTrips.value.length) {
          updateMap(filteredTrips.value[0]);
        }
      });
    }
  },
  { immediate: true },
);

function initializeMap() {
  if (!mapContainer.value || gmap) return;
  gmap = new google.maps.Map(mapContainer.value, {
    center: { lat: 13.7563, lng: 100.5018 },
    zoom: 6,
    mapTypeControl: false,
    streetViewControl: false,
    fullscreenControl: true,
  });
  geocoder = new google.maps.Geocoder();
  placesService = new google.maps.places.PlacesService(gmap);
  mapReady.value = true;
}
</script>

<style scoped>
.trip-card {
  transition: all 0.3s ease;
  cursor: pointer;
}

.trip-card:hover {
  /* transform: translateY(-2px); */
  box-shadow: 0 10px 25px rgba(59, 130, 246, 0.1);
}

.tab-button {
  transition: all 0.3s ease;
}

.tab-button.active {
  background-color: #3b82f6;
  color: white;
  box-shadow: 0 4px 14px rgba(59, 130, 246, 0.3);
}

.tab-button:not(.active) {
  background-color: white;
  color: #6b7280;
  border: 1px solid #d1d5db;
}

.tab-button:not(.active):hover {
  background-color: #f9fafb;
  color: #374151;
}

#map {
  height: 100%;
  min-height: 600px;
  border-radius: 0 0 0.5rem 0.5rem;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.875rem;
  font-weight: 500;
}

.status-pending {
  background-color: #fef3c7;
  color: #d97706;
}

.status-confirmed {
  background-color: #d1fae5;
  color: #065f46;
}

.status-rejected {
  background-color: #fee2e2;
  color: #dc2626;
}

.status-cancelled {
  background-color: #f3f4f6;
  color: #6b7280;
}

@keyframes slide-in-from-top {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-in {
  animation-fill-mode: both;
}

.slide-in-from-top {
  animation-name: slide-in-from-top;
}

.duration-300 {
  animation-duration: 300ms;
}
</style>
