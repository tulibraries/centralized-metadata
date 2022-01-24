require "test_helper"

class RecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @record = records(:one)
  end

  test "should get index" do
    get records_url, as: :json
    assert_response :success
  end

  test "should create record" do
    assert_difference("Record.count") do
      post records_url, params: { record: { id: @record.id, import_method: @record.import_method, lc_class: @record.lc_class, local_note: @record.local_note, local_pref_label: @record.local_pref_label, local_var_label: @record.local_var_label, pref_label: @record.pref_label, see_also: @record.see_also, skos_close_match: @record.skos_close_match, skos_exact_match: @record.skos_exact_match, source_vocab: @record.source_vocab, type: @record.type, var_label: @record.var_label } }, as: :json
    end

    assert_response :created
  end

  test "should show record" do
    get record_url(@record), as: :json
    assert_response :success
  end

  test "should update record" do
    patch record_url(@record), params: { record: { id: @record.id, import_method: @record.import_method, lc_class: @record.lc_class, local_note: @record.local_note, local_pref_label: @record.local_pref_label, local_var_label: @record.local_var_label, pref_label: @record.pref_label, see_also: @record.see_also, skos_close_match: @record.skos_close_match, skos_exact_match: @record.skos_exact_match, source_vocab: @record.source_vocab, type: @record.type, var_label: @record.var_label } }, as: :json
    assert_response :success
  end

  test "should destroy record" do
    assert_difference("Record.count", -1) do
      delete record_url(@record), as: :json
    end

    assert_response :no_content
  end
end
