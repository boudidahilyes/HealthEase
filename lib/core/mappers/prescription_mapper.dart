import 'package:healthease/core/dto/prescription_dto.dart' as dto;
import 'package:healthease/core/models/prescription.dart' as prescriptionLocal;
import 'package:healthease/core/models/medicine.dart' as medicineLocal;


prescriptionLocal.Prescription prescriptionDtoToLocal(dto.PrescriptionDto d) {
  return prescriptionLocal.Prescription(
    id: d.id,
    patientId: d.patientId,
    doctorId: d.doctorId,
    description: d.description,
    createdAt: d.createdAt,
  );
}

medicineLocal.Medicine medicineDtoToLocal(dto.Medicine m, {required int prescriptionId}) {
  return medicineLocal.Medicine(
    id: m.id,
    name: m.name,
    startDate: m.startDate,
    endDate: m.endDate,
    dosePerDay: m.dosePerDay,
    mgPerDose: m.mgPerDose,
    remaining: m.remaining,
    prescriptionId: prescriptionId,
    status: m.isActive ? medicineLocal.MedicineStatus.active : medicineLocal.MedicineStatus.inactive,
  );
}