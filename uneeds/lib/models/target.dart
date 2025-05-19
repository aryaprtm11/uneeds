class TargetPersonal {
  final String judulTarget, deadline;
  TargetPersonal({required this.judulTarget, required this.deadline});
}

class CapaianTarget {
  final int idTarget, status;
  final String deskripsiCapaian;
  CapaianTarget({
    required this.idTarget,
    required this.deskripsiCapaian,
    this.status = 0,
  });
}
