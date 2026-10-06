import pytest

from reader.extract import (
    HourCategory,
    classify,
    find_hours,
    find_issuer,
    find_title,
    title_from_file_name,
)


@pytest.mark.parametrize(
    ("text", "hours"),
    [
        ("carga horária de 20 horas", 20),
        ("Carga Horaria: 10h00", 10),
        ("com duração de 8h", 8),
        ("40 (quarenta) horas", 40),
        ("totalizando 12 hrs de atividades", 12),
        ("com 10h30 de duração", 10),
    ],
)
def test_ca08_finds_the_hours(text, hours):
    assert find_hours(text) == hours


def test_ca09_prefers_the_workload_over_clock_times():
    text = "das 8h às 12h, com carga horária total de 4 horas"
    assert find_hours(text) == 4


def test_ca09_ignores_clock_times_without_a_workload():
    assert find_hours("evento das 8h às 12h no auditório") is None
    assert find_hours("início às 14h") is None


@pytest.mark.parametrize(
    "text",
    ["realizado em 12/03/2026", "1200 horas", "carga horária de 0 horas", ""],
)
def test_ca09_finds_nothing_outside_1_to_999_hours(text):
    assert find_hours(text) is None


@pytest.mark.parametrize(
    ("text", "category"),
    [
        (
            "participou do projeto de Extensão Horta Comunitária",
            HourCategory.EXTENSION,
        ),
        ("ação extensionista na comunidade", HourCategory.EXTENSION),
        ("PROJETO DE EXTENSAO", HourCategory.EXTENSION),
        ("participou da Semana Acadêmica", HourCategory.COMPLEMENTARY),
    ],
)
def test_ca10_classifies_extension_and_complementary(text, category):
    assert classify(text) == category


def test_ca11_takes_the_quoted_title_after_the_event():
    text = (
        'Certificamos que Ana Souza participou do evento "Semana Acadêmica '
        'de Computação", com carga horária de 20 horas.'
    )
    assert find_title(text, "x.pdf") == "Semana Acadêmica de Computação"


def test_ca11_takes_curly_quotes_and_line_breaks():
    text = "concluiu o curso\n“Introdução ao\nPython”, realizado online"
    assert find_title(text, "x.pdf") == "Introdução ao Python"


def test_ca11_takes_the_text_up_to_the_comma_without_quotes():
    text = "participou do Workshop de Robótica, realizado em março"
    assert find_title(text, "x.pdf") == "Workshop de Robótica"


def test_ca11_falls_back_to_the_file_name():
    text = "Certificado de participação. Carga horária: 10 horas."
    assert find_title(text, "certificado-game-jam.pdf") == "Certificado Game Jam"


def test_ca11_file_name_rule():
    assert title_from_file_name("semana_academica-2026.PDF") == (
        "Semana Academica 2026"
    )


def test_ca11_title_is_at_most_120_characters():
    text = "participou do " + "a" * 300
    assert len(find_title(text, "x.pdf")) <= 120


def test_ca13_issuer_is_the_institution_when_it_appears_in_the_text():
    assert find_issuer("Universidade Tecnológica (UTFPR)", "UTFPR") == "UTFPR"
    assert find_issuer("emitido pela utfpr", "UTFPR") == "UTFPR"
    assert find_issuer("emitido pela UFPR", "UTFPR") is None
